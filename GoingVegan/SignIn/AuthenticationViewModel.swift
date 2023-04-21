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
import AuthenticationServices

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
    var deletingUser = false
    var alreadyCalledSignedIn = false
    var group = DispatchGroup()
    var dateFormatter = DateFormatter()
    var groceryListString = ""
    var appleCoordinator = SignInWithAppleCoordinator()
    var appleSignInDelegates: SignInWithAppleDelegates! = nil
    let onLoginEvent: ((SignInWithAppleToFirebaseResponse) -> ())?
    
    init(_ onLoginEvent: ((SignInWithAppleToFirebaseResponse)-> ())? = nil){
        ref = Database.database(url: "https://goingvegan-a8777-default-rtdb.firebaseio.com/").reference()
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        self.onLoginEvent = onLoginEvent
        listen()
    }
    
    func signInWithApple() {
        let request = self.appleCoordinator.appleIDRequest()
        self.appleSignInDelegates = SignInWithAppleDelegates(viewModel: self, window: nil, currentNonce: self.appleCoordinator.currentNonce ?? "", onLoginEvent: self.onLoginEvent)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self.appleSignInDelegates
        controller.performRequests()
        
    }
    //REVIEW AGAINST GOOGLE
    func linkingWithApple (credential: AuthCredential) {
        guard let user = Auth.auth().currentUser, let sess = self.session else {
            print("failed to retrieve user\n")
            return
        }
        user.link(with: credential) { (result, error) in
            if let error = error, (error as NSError).code == AuthErrorCode.credentialAlreadyInUse.rawValue
            {
                
                print("The user you're signing in with has already been linked, signing in to the new user and migrating the anonymous users [\(sess.uid)] tasks.")

            if let updatedCredential = (error as NSError).userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? OAuthCredential {
                print("Signing in using the updated credentials")
                Auth.auth().signIn(with: updatedCredential) { (result, error) in

                    if let error = error {
                        self.signInErrorMessage = error.localizedDescription
                        print(error.localizedDescription)
                        self.state = .signedOut
                        return
                    }
                    self.listen()
                  }
                }
            }
        }
    }
    
    
    func signIn() {
        self.creatingUser = false
        self.deletingUser = false
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
    
    let configuration = GIDConfiguration(clientID: clientID)
    
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
    guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
    
      GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
        authenticateUserFromGoogle(for: user, with: error)
      }
    }
    
    func authenticateUserFromGoogle(for user: GIDGoogleUser?, with error: Error?) {
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
                self.state = .signedOut
                return
            }
           listen()
        }
    }
    
    func createUser(username: String, password: String) {
       self.creatingUser = true
       self.group.enter()
        DispatchQueue.main.async {
            Auth.auth().createUser(withEmail: username, password: password) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                    self.createUserErrorMessage = error.localizedDescription
                }

                self.state = .signedOut
                self.group.leave()
                return
            }
        }
    }
    
    func deleteUser() {
        guard let user = Auth.auth().currentUser else {return}
        self.deletingUser = true

        self.ref.child(user.uid).removeValue {_,_ in
            user.delete { error in
              if let error = error {
                  print(error.localizedDescription)
                  return
              }
             
             self.state = .signedOut
            }
        }
    }
    
    func signInWithEmail (username: String, password: String) {
        self.creatingUser = false
        self.deletingUser = false
        self.group.enter()
        DispatchQueue.main.async {
            Auth.auth().signIn(withEmail: username, password: password) { [weak self] _, error in
                
                if let error = error {
                    self?.signInErrorMessage = error.localizedDescription
                    print(error.localizedDescription)
                    self?.state = .signedOut
                    return
                }
                self?.listen()
                self?.group.leave()
                return
            }
        }
    }
    
    
    func signOut() {
        if let sess = self.session, let days = sess.veganDays
        {
            let savedDatesString = days.map {dateFormatter.string(from: $0)}
            var i = 0
            let uniqueDatesString = Array(Set(savedDatesString))
            let savedDatesCount = uniqueDatesString.count
            if savedDatesCount == 0 {
                self.ref.child("users").child(sess.uid).updateChildValues(["veganDays*":nil])
            }
        while i < savedDatesCount{
            let dateString = "\(uniqueDatesString[i])"
            self.ref.child("users").child(sess.uid).updateChildValues(["veganDays\(i)":String(dateString)])
            print(dateString)
                i+=1;
            }
            
        }
    
      GIDSignIn.sharedInstance.signOut()
      
      do {
        // 2
          self.session = nil
        try Auth.auth().signOut()
        state = .signedOut
      } catch {
        print(error.localizedDescription)
      }
        alreadyCalledSignedIn = false
    }
   
    
    func listen () {
        // monitor authentication changes using firebase
        if !self.creatingUser{
                self.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        if self.listenerCount > 0 && !self.creatingUser && !self.deletingUser{
                            print("Got user: \(user)")
                            self.session = User(
                                uid: user.uid,
                                displayName: user.displayName,
                                email: user.email,
                                days: []
                            )
                            
                            self.session = self.populateSavedData(userOptional: self.session)
                            self.ref.child("users/\(String(describing: self.session?.uid))/veganDays*").getData(completion:  { error, snapshot in
                                guard error == nil else {
                                    print(error!.localizedDescription)
                                    return;
                                }
                                guard let days = snapshot?.value as? [Date] else {return}
                                self.session?.veganDays = days
                            });
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
                if !self.alreadyCalledSignedIn {
                    self.alreadyCalledSignedIn = true
                    self.state = .signedIn
                   
                }
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
        let uniqueDays = Array(Set(days))
        self.veganDays = uniqueDays
    }
}

enum SignInWithAppleToFirebaseResponse {
        case success
        case error
}

class SignInWithAppleDelegates: NSObject {
    let onLoginEvent: ((SignInWithAppleToFirebaseResponse) -> ())?
    weak var window: UIWindow!
    var currentNonce: String?
    var authViewModel: AuthenticationViewModel!
    
    init(viewModel:AuthenticationViewModel, window: UIWindow?, currentNonce: String, onLoginEvent: ((SignInWithAppleToFirebaseResponse)-> ())? = nil){
        self.window = window
        self.currentNonce = currentNonce
        self.onLoginEvent = onLoginEvent
        self.authViewModel = viewModel
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
