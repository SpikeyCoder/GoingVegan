//
//  QuickSignInWithApple.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/13/23.
//

import SwiftUI
import AuthenticationServices

struct QuickSignInWithApple: UIViewRepresentable {
  typealias UIViewType = ASAuthorizationAppleIDButton
  
  func makeUIView(context: Context) -> UIViewType {
    return ASAuthorizationAppleIDButton()
    // or just use UIViewType() 😊 Not recommanded though.
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
  }
}

struct QuickSignInWithApple_Previews: PreviewProvider {
    static var previews: some View {
        QuickSignInWithApple()
    }
}
