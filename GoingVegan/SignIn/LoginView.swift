//
//  LoginView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/9/23.
//
import Foundation
import SwiftUI
import CoreData
import AuthenticationServices
import CryptoKit

let storedUsername = "Myusername"
let storedPassword = "Mypassword"

struct LoginView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
      
    
    @State var username: String = ""
    @State var password: String = ""
    let darkRed = Color(red: 0.7326, green: 0.1925, blue: 0.0749)
    @State var signInHandler: SignInWithAppleCoordinator?
    
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    @State var createUserCompleted: Bool = false
    @State private var isPresented: Bool = Bool()
    @State private var showingTransition = true
    
    private func showAppleLoginView() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.performRequests()
      }
    
    var body: some View {
        NavigationView {
            
        VStack() {
            TitleText()
                .padding([.top,.bottom], UIScreen.main.bounds.size.height/20.0)
            LoginIcon()
            .padding(.bottom, UIScreen.main.bounds.size.height/20.0)
            VStack() {
                UsernameField(username: $username)
                PasswordField(password: $password)
            }
            .padding([.leading, .trailing],UIScreen.main.bounds.size.width/2.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        
            
            if authenticationDidFail {
                let darkRed = Color(red: 0.7326, green: 0.1925, blue: 0.0749)
                if let errorMessage = viewModel.signInErrorMessage {
                    Spacer()
                    Text(errorMessage.count < 50 ? String(viewModel.signInErrorMessage!) : "Username and/or password is incorrect.").foregroundColor(darkRed).onAppear(perform: setDismissTimer).padding([.top, .bottom], 40)
                        .frame(
                            minWidth: 0,
                            maxWidth: UIScreen.main.bounds.size.width/2.34,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .center
                        ).multilineTextAlignment(.center)
                }
                
            }
            Button(action: {
                viewModel.signInWithEmail(username: username, password: password)
                viewModel.group.notify(queue: .main){
                    authenticationDidFail = true
                }
                
            }) {
                SignInButtonText()
            }
            
            Button(action: { isPresented.toggle() }){
                CreateUserButtonText()
            }
            .padding(.bottom, 0)
            Text("--OR--")
                .padding(.bottom, -5)
            GoogleSignInButton()
              .frame(width: UIScreen.main.bounds.size.width/2.0, height: UIScreen.main.bounds.size.height/10.0)
              .shadow(radius: 10.0, x: 20, y: 10)
              .onTapGesture {
                viewModel.signIn()
              }
            SignInWithAppleButton()
            .frame(width: UIScreen.main.bounds.size.width/2.0, height: UIScreen.main.bounds.size.height/25.0)
            .shadow(radius: 10.0, x: 20, y: 10)
            .onTapGesture { 
                viewModel.signInWithApple()
          }
            .padding(.bottom, UIScreen.main.bounds.size.height/5.0)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .edgesIgnoringSafeArea(.all)
          
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showingTransition = false
            }
        }.sheet(isPresented: $showingTransition) {
            TransitionView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .edgesIgnoringSafeArea(.all)
        }
        .customPopupView(isPresented: $isPresented, popupView: {popupView})
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .edgesIgnoringSafeArea(.all)
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
    
    var popupView: some View {
        
        RoundedRectangle(cornerRadius: 20.0)
            .fill(Color.white)
            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height/2.0)
            .overlay(
                
                Image(systemName: "xmark").resizable().frame(width: 10.0, height: 10.0)
                    .foregroundColor(Color.black)
                    .padding(5.0)
                    .background(Color.white)
                    .clipShape(Circle())
                    .padding()
                    .onTapGesture {
                        isPresented.toggle()
                        self.username = ""
                        self.password = ""
                    }
                
                , alignment: .topLeading)
        
            .overlay(
                VStack{
                    Text("Create a Username and Password")
                    UsernameField(username: $username)
                    PasswordField(password: $password)
                    if createUserCompleted {
                        if let errorMessage = viewModel.createUserErrorMessage {
                             Text(errorMessage.count < 60 ? String(viewModel.createUserErrorMessage!) : "Username and/or password is incomplete.")
//                                .foregroundColor(darkRed).onAppear(perform: setDismissTimer)
                
                        }else{
                            Text("Successfully created account")
                        }
                        
//                            .foregroundColor(darkRed).onAppear(perform: setDismissTimer) as! Text
                    }
                    Button(action: {
                        viewModel.createUser(username: username, password: password)
                        viewModel.group.notify(queue: .main){
                            createUserCompleted = true
                            
                        }
                    }) {
                        CreateUserButtonText()
                    }.padding([.top,.bottom], 50)
                    
                }
                , alignment: .center)
            .transition(AnyTransition.scale)
            .shadow(radius: 10.0)
    }
    
}



struct CustomPopupView<Content, PopupView>: View where Content: View, PopupView: View {
    
    @Binding var isPresented: Bool
    @ViewBuilder let content: () -> Content
    @ViewBuilder let popupView: () -> PopupView
    let backgroundColor: Color
    let animation: Animation?
    
    var body: some View {
        
        content()
            .animation(nil, value: isPresented)
            .overlay(isPresented ? backgroundColor.ignoresSafeArea() : nil)
            .overlay(isPresented ? popupView() : nil)
            .animation(animation, value: isPresented)
        
    }
}

extension View {
    func customPopupView<PopupView>(isPresented: Binding<Bool>, popupView: @escaping () -> PopupView, backgroundColor: Color = .black.opacity(0.7), animation: Animation? = .default) -> some View where PopupView: View {
        return CustomPopupView(isPresented: isPresented, content: { self }, popupView: popupView, backgroundColor: backgroundColor, animation: animation)
    }
}

struct TitleText : View {
    var body: some View {
        return Text("Going Vegan")
            .font(.largeTitle).foregroundColor(Color.white)
            .fontWeight(.semibold)
            .padding([.top, .bottom], 30)
            .shadow(radius: 10.0, x: 20, y: 10)
    }
}

struct LoginIcon : View {
    var body: some View {
        return Image("goingveganicon")
            .resizable()
            .frame(width: UIScreen.main.bounds.size.width/4.0, height: UIScreen.main.bounds.size.height/8.0)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 10, x: 20, y:10)
            .padding(.bottom, 30)
    }
}

struct UsernameField : View {
    @Binding var username: String
    var body: some View {
        return TextField("Email", text: $username)
            .padding()
            .frame(width: UIScreen.main.bounds.size.width/2.0, height: UIScreen.main.bounds.size.height/20.0)
            .cornerRadius(20.0)
            .background(Color.themeTextField)
    }
}

struct PasswordField : View {
    @Binding var password: String
    var body: some View {
        return SecureField("Password", text: $password)
            .padding()
            .frame(width: UIScreen.main.bounds.size.width/2.0, height:UIScreen.main.bounds.size.height/20.0)
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
            .frame(width: UIScreen.main.bounds.size.width/2.0, height: UIScreen.main.bounds.size.height/30.0)
            .background(Color.blue)
            .cornerRadius(5.0)
            .shadow(radius: 10.0, x: 20, y: 10)
    }
}

struct CreateUserButtonText : View {
    var body: some View {
        return Text("Create Account")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: UIScreen.main.bounds.size.width/2.0, height: UIScreen.main.bounds.size.height/30.0)
            .background(Color.purple)
            .fontWeight(.semibold)
            .cornerRadius(5.0)
            .shadow(radius: 10.0, x: 20, y: 10)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}



extension Color {
    static var themeTextField: Color {
        return Color(red: 220.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, opacity: 1.0)
    }
}


