//
//  ContentView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/9/23.
//
import Foundation
import SwiftUI
import CoreData
import AuthenticationServices

let storedUsername = "Myusername"
let storedPassword = "Mypassword"

struct LoginView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    @State var username: String = ""
    @State var password: String = ""
    
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    
    private func showAppleLoginView() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        //controller.delegate = SignInWithAppleViewModel
        controller.performRequests()
      }
    
    var body: some View {
    
        VStack() {
            TitleText()
            LoginIcon()
            VStack(alignment: .leading, spacing: 15) {
                UsernameField(username: $username)
                PasswordField(password: $password)
            }.padding([.leading, .trailing],27.5)
        
            
            if authenticationDidFail {
                let darkRed = Color(red: 0.7326, green: 0.1925, blue: 0.0749)
                Text(viewModel.signInErrorMessage != nil ? String(viewModel.signInErrorMessage!) : "").foregroundColor(darkRed).onAppear(perform: setDismissTimer).padding([.top, .bottom], 40)
                    .frame(
                        minWidth: 0,
                        maxWidth: 500,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .center
                    ).multilineTextAlignment(.center)
            }
            Button(action: {
                viewModel.signInWithEmail(username: username, password: password)
                viewModel.group.notify(queue: .main){
                    authenticationDidFail = true
                }
                
            }) {
                SignInButtonText()
            }.padding(.top, 50)
         
            Spacer()
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                    .padding()
            }
            Button(action: {
                viewModel.createUser(username: username, password: password)
            }) {
                CreateUserButtonText()
            }.padding(.top, 50)
//           QuickSignInWithApple()
//                    .frame(width: 280, height: 60, alignment: .center)
//                    .onTapGesture(perform: showAppleLoginView)
          
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
    }
    
    
    func setDismissTimer() {
      let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
        withAnimation(.easeInOut(duration: 1)) {
            authenticationDidFail = false;
        }
        timer.invalidate()
      }
      RunLoop.current.add(timer, forMode:RunLoop.Mode.default)
    }
    
    
    
}

struct TitleText : View {
    var body: some View {
        return Text("Going Vegan")
            .font(.largeTitle).foregroundColor(Color.white)
            .fontWeight(.semibold)
            .padding([.top, .bottom], 40)
            .shadow(radius: 10.0, x: 20, y: 10)
    }
}

struct LoginIcon : View {
    var body: some View {
        return Image("goingveganicon")
            .resizable()
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 10, x: 20, y:10)
            .padding(.bottom, 50)
    }
}

struct UsernameField : View {
    @Binding var username: String
    var body: some View {
        return TextField("Email", text: $username)
            .padding()
            .frame(width: 340, height: 55)
            .cornerRadius(20.0)
            .background(Color.themeTextField)
    }
}

struct PasswordField : View {
    @Binding var password: String
    var body: some View {
        return SecureField("Password", text: $password)
            .padding()
            .frame(width: 340, height: 55)
            .cornerRadius(20.0)
            .background(Color.themeTextField)
    }
}



struct SignInButtonText : View {
    var body: some View {
        return Text("Sign In")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 300, height: 50)
            .background(Color.blue)
            .cornerRadius(15.0)
            .shadow(radius: 10.0, x: 20, y: 10)
    }
}

struct CreateUserButtonText : View {
    var body: some View {
        return Text("Create User")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 300, height: 50)
            .background(Color.blue)
            .cornerRadius(15.0)
            .shadow(radius: 10.0, x: 20, y: 10)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct SignInWithAppleSwiftUIButton: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
      if colorScheme.self == .dark {
          SignInButton(SignInWithAppleButton.Style.whiteOutline)
      }
      else {
          SignInButton(SignInWithAppleButton.Style.black)
      }
    }

    func SignInButton(_ type: SignInWithAppleButton.Style) -> some View{
        print("Made it here")
        return SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authResults):
                print("Authorisation successful \(authResults)")
            case .failure(let error):
                print("Authorisation failed: \(error.localizedDescription)")
            }
        }
        .frame(width: 280, height: 60, alignment: .center)
        .signInWithAppleButtonStyle(type)
    }
}


extension Color {
    static var themeTextField: Color {
        return Color(red: 220.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, opacity: 1.0)
    }
}
