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

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    
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
                UsernameField()
                PasswordField()
            }.padding([.leading, .trailing],27.5)
            
            Button(action: {
                isLoggedIn = true
            }) {
                SignInButtonText()
            }.padding(.top, 50)
            
            Spacer()
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                    .padding()
            }
           QuickSignInWithApple()
                    .frame(width: 280, height: 60, alignment: .center)
                    .onTapGesture(perform: showAppleLoginView)
          
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
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
    @State private var email = ""
    var body: some View {
        return TextField("Email", text: self.$email)
            .padding()
            .frame(width: 340, height: 55)
            .cornerRadius(20.0)
            .background(Color.themeTextField)
    }
}

struct PasswordField : View {
    @State private var password = ""
    var body: some View {
        return SecureField("Password", text: self.$password)
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


// WAY TO CALL APIS VIA A BUTTON
/* Button {
     Task {
         let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.chucknorris.io/jokes/random")!)
                         let decodedResponse = try? JSONDecoder().decode(Joke.self, from: data)
         joke = decodedResponse?.value ?? ""
     }
 } label: {
     Text("Fetch Joke")
 } */
