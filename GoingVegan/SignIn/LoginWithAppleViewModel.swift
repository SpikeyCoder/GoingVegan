//
//  LoginWithAppleViewModel.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/13/23.
//

import Foundation
import AuthenticationServices

class SignInWithAppleViewModel: NSObject, ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
      case let appleIdCredential as ASAuthorizationAppleIDCredential:
        print("\n ** ASAuthorizationAppleIDCredential - \(#function)** \n")
        print(appleIdCredential.email ?? "Email not available.")
        print(appleIdCredential.fullName ?? "fullname not available")
        print(appleIdCredential.fullName?.givenName ?? "givenName not available")
        print(appleIdCredential.fullName?.familyName ?? "Familyname not available")
        print(appleIdCredential.user)  // This is a user identifier
        print(appleIdCredential.identityToken?.base64EncodedString() ?? "Identity token not available") //JWT Token
        print(appleIdCredential.authorizationCode?.base64EncodedString() ?? "Authorization code not available")
        break
        
      case let passwordCredential as ASPasswordCredential:
        print("\n ** ASPasswordCredential ** \n")
        print(passwordCredential.user)  // This is a user identifier
        print(passwordCredential.password) //The password
        break
        
      default:
        break
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    print("\n -- ASAuthorizationControllerDelegate -\(#function) -- \n")
    print(error)
  }
}
