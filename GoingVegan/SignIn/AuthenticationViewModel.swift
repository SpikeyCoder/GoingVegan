//
//  AuthenticationViewModel.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/30/23.
//
import Foundation
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import SwiftUI
import Combine

class AuthenticationViewModel: ObservableObject {
    
    enum SignInState {
        case signedIn
        case signedOut
    }
    
    @Published var state: SignInState = .signedOut
    var didChange = PassthroughSubject<Any,Never>()
    var session: User? { didSet { self.didChange.send(self) }}
    var handle: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    var listenerCount = 0
    var signInErrorMessage: String?
    var createUserErrorMessage: String?
    var creatingUser = false
    var group : DispatchGroup!
    var dateFormatter = DateFormatter()
    
    init(){
        listen()
        ref = Database.database(url: "https://goingvegan-a8777-default-rtdb.firebaseio.com/").reference()
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    }
    
    func signIn() {
      if GIDSignIn.sharedInstance.hasPreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
            authenticateUser(for: user, with: error)
        }
      } else {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
       
        let configuration = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
          GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
            authenticateUser(for: user, with: error)
          }
      }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
      if let error = error {
          self.signInErrorMessage = error.localizedDescription
        print(error.localizedDescription)
        return
      }
      
      guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
      
      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
   
      Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
        if let error = error {
            self.signInErrorMessage = error.localizedDescription
          print(error.localizedDescription)
        } else {
          state = .signedIn
        }
      }
    }
    
    func createUser(username: String, password: String) {
       self.group = DispatchGroup()
       self.group.enter()
        DispatchQueue.main.async {
            Auth.auth().createUser(withEmail: username, password: password) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                    self.createUserErrorMessage = error.localizedDescription
                }

                self.state = .signedOut
                self.creatingUser = true
                self.group.leave()
                return
            }
        }
    }
    
    func deleteUser() {
        let user = Auth.auth().currentUser

        user?.delete { error in
          if let error = error {
              print(error.localizedDescription)
          } else {
            // Account deleted.
          }
        }
    }
    
    func signInWithEmail (username: String, password: String) {
        self.group = DispatchGroup()
        self.group.enter()
        DispatchQueue.main.async {
            Auth.auth().signIn(withEmail: username, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    self?.signInErrorMessage = error.localizedDescription
                    print(error.localizedDescription)
                    strongSelf.state = .signedOut
                    guard let group = self?.group else {return}
                    group.leave()
                    return
                }
                guard let sess = strongSelf.session else {return}
                self?.ref.child("users/\(sess.uid)/veganDays*").getData(completion:  { error, snapshot in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        guard let group = self?.group else {return}
                        group.leave()
                        return;
                    }
                    guard let days = snapshot?.value as? [Date] else {return}
                    sess.veganDays = days
                    self?.session = sess
                    self?.state = .signedIn
                    guard let group = self?.group else {return}
                    group.leave()
                });
            }
        }
    }
    
    func signOut() {
        if let sess = self.session, let days = sess.veganDays
        {
            ref.child("users").child(sess.uid).removeValue()
            let savedDatesString = days.map {dateFormatter.string(from: $0)}
            var i = 0
            let savedDatesCount = savedDatesString.count
           
        while i < savedDatesCount{
            let dateString = "\(savedDatesString[i])"
            self.ref.child("users").child(sess.uid).updateChildValues(["veganDays\(i)":String(dateString)])
            print(dateString)
                i+=1;
            }
            
        }else {}
    
      GIDSignIn.sharedInstance.signOut()
      
      do {
        // 2
          self.session = nil
        try Auth.auth().signOut()
        state = .signedOut
      } catch {
        print(error.localizedDescription)
      }
    }
   
    
    func listen () {
        // monitor authentication changes using firebase
        if !self.creatingUser{
                self.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        if self.listenerCount > 0{
                            print("Got user: \(user)")
                            self.session = User(
                                uid: user.uid,
                                displayName: user.displayName,
                                email: user.email,
                                days: []
                            )
                            
                            self.session = self.populateSavedData(userOptional: self.session)
                        }
                        self.listenerCount += 1
                    }
                    
                    }
            }
    }
     
    
    func populateSavedData(userOptional:User?) -> User {
        guard let user = userOptional else {
            self.state = .signedOut
            return self.session ?? User(uid: "", displayName: "false", email:"", days:[])}
        self.group = DispatchGroup()
        self.group.enter()
        DispatchQueue.main.async {
            self.ref.child("users/\(user.uid)").getData(completion:  { error, snapshot in
              guard error == nil else {
                print(error!.localizedDescription)
                return;
              }
                if let days = snapshot?.value as? Any {
                    let daysArray = days as? Dictionary<String,AnyObject> ?? Dictionary<String,AnyObject>()
                    for (kind,numbers) in daysArray {
                        print("kind: \(kind)")
                        let dateFromString = self.dateFormatter.date(from: numbers as! String)
                        self.session?.veganDays?.append(dateFromString!)
                    }
                    
                }
               
                self.group.leave()
                self.state = .signedIn
                
            });
        }
        return user;
    }
}

class User {
    var uid: String
    var email: String?
    var displayName: String?
    var veganDays: [Date]?

    init(uid: String, displayName: String?, email: String?, days: [Date]?) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.veganDays = days
    }
    
    func saveDays(days:[Date]){
        self.veganDays = days
    }
}

extension AuthenticationViewModel {
    func convertSignInStateToBool() -> Bool {
        if self.state == .signedIn{
            return true
        }
        return false
    }
}
