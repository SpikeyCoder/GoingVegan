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
 
  private weak var window: UIWindow!
  private var onSignedIn: ((User) -> Void)? // (2)

  private var currentNonce: String? // (3)
  
  init(window: UIWindow?) {
    self.window = window
  }

//    private func appleIDRequest(withState: SignInState) -> ASAuthorizationAppleIDRequest {
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest() // (1)
//        request.requestedScopes = [.fullName, .email] // (2)
//        request.state = withState.rawValue //(3)
//
//        let nonce = randomNonceString() // (4)
//        currentNonce = nonce
//        request.nonce = sha256(nonce)
//
//        return request
//      }
    
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
