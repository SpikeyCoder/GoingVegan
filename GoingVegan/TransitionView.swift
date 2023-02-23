//
//  TransitionView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/23/23.
//

import SwiftUI

struct TransitionView: View {
    @State private var isLoading = false
    
    var body: some View {
            ZStack {

                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 14)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: 0.2)
                    .stroke(Color.green, lineWidth: 7)
                    .frame(width: 100, height: 100)
                    .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                    .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false))
                    .onAppear() {
                        self.isLoading = true
                }
            }
        }
}

struct TransitionView_Previews: PreviewProvider {
    static var previews: some View {
        TransitionView()
    }
}
