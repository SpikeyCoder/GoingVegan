//
//  SplashScreen.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/1/23.
//

import SwiftUI

struct SplashScreen: View {
    
    @State var animationValues: [Bool] = Array(repeating: false, count: 10)
    
    var body: some View {
        ZStack {
            ZStack{
              
                if animationValues[1] {
                    Circle()
                        .fill(.black)
                        .frame(width: 30, height: 30)
                        .offset(x:animationValues[2] ? 35 : 0)
                }
                
                Circle()
                    .fill(.black)
                    .frame(width: 30, height: 30)
                    .scaleEffect(animationValues[0] ? 1 : 0, anchor: .bottom)
                    .offset(x:animationValues[2] ? -35 : 0)
                
                ZStack {
                    
                    Circle()
                        .stroke(Color.black,lineWidth: 10)
                        .frame(width: 65, height: 65)
                        .offset(x: -35)
                    
                    Circle()
                        .stroke(Color.black,lineWidth: 10)
                        .frame(width: 65, height: 65)
                        .offset(x: 35)
                    
                    Circle()
                        .trim(from: 0.6, to: 1)
                        .stroke(Color.black,lineWidth: 10)
                        .frame(width: 130, height: 130)
                        .rotationEffect(.init(degrees: -20))
                        .offset(y:12)
                        .scaleEffect(1.07)
                    
                    
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .offset(y: 35)
                        .scaleEffect(CGSize(width: 1.3, height: 1), anchor: .top)
                        .background(
                            Circle()
                                .fill(.black)
                                .frame(width: 15, height: 15)
                                .offset(y: 25)
                            
                            ,alignment: .top
                        )
                    
                }
                .opacity(animationValues[3] ? 1 : 0)
                
            }
            .environment(\.colorScheme, .light)
        }
        .onAppear {
            
            withAnimation(.easeInOut(duration: 0.3)){
                animationValues[0] = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
                animationValues[1] = true
                
                withAnimation(.easeInOut(duration: 0.4).delay(0.1)){
                    animationValues[2] = true
                }
                
                withAnimation(.easeInOut(duration: 0.3).delay(0.45)) {
                    animationValues[3] = true
                }
                
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
