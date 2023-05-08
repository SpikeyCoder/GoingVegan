//
//  SignInWithAppleCoordinator.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/28/23.
//
import SwiftUI
import Firebase
import Foundation
import AuthenticationServices
import CryptoKit


class SignInWithAppleCoordinator: NSObject {
    
  @EnvironmentObject var viewModel: AuthenticationViewModel

  var currentNonce: String?
  var appleCredential: ASAuthorizationAppleIDCredential?
  var token: String?
  
    func appleIDRequest() -> ASAuthorizationAppleIDRequest {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.state = "signIn"
        request.nonce = sha256(nonce)

        return request
      }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

 

extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {
    func firebaseLogin(credential: ASAuthorizationAppleIDCredential) {
        // 3
//        guard let nonce = currentNonce else {
//          fatalError("Invalid state: A login callback was received, but no login request was sent.")
//        }
//        guard let appleIDToken = credential.identityToken else {
//          print("Unable to fetch identity token")
//          return
//        }
//        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//          return
//        }
        // Initialize a Firebase credential.
//       let oAuthCredential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                  idToken: idTokenString,
//                                                  rawNonce: nonce)
        // Sign in with Firebase.
        let username = credential.user + "@icloud.com"
        let password = String(credential.user)
        self.authViewModel.signInWithEmail(username: username, password: password)
        
        authViewModel.group.notify(queue: .main){
            self.authViewModel.state = .signedIn
            self.onLoginEvent?(.success)
        }
        
    }
    
    func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
        let username = credential.user + "@icloud.com"
        let password = String(credential.user)
        authViewModel.createUser(username: username, password: password)
        self.authViewModel.group.notify(queue: .main){
            self.firebaseLogin(credential: credential)
        }
    }

    private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
        self.firebaseLogin(credential: credential)
    }


    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                registerNewAccount(credential: appleIdCredential)
            } else {
                signInWithExistingAccount(credential: appleIdCredential)
            }
            break
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.onLoginEvent?(.error)
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window
    }
}
