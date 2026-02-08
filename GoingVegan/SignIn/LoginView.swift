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

struct LoginView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var username: String = ""
    @State var password: String = ""
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    @State var createUserCompleted: Bool = false
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        TitleText()
                        LoginIcon()
                    }
                    .padding(.top, 40)
                    
                    // Email/Password Login Section
                    VStack(spacing: 16) {
                        UsernameField(username: $username)
                        PasswordField(password: $password)
                        
                        // Error Message
                        if authenticationDidFail {
                            if let errorMessage = viewModel.signInErrorMessage {
                                Text(errorMessage.count < 50 ? errorMessage : "Username and/or password is incorrect.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .onAppear(perform: setDismissTimer)
                                    .transition(.opacity)
                            }
                        }
                        
                        // Sign In Button
                        Button(action: {
                            viewModel.signInWithEmail(username: username, password: password)
                            viewModel.group.notify(queue: .main) {
                                authenticationDidFail = true
                            }
                        }) {
                            SignInButtonText()
                        }
                        .disabled(username.isEmpty || password.isEmpty)
                        
                        // Create Account Button
                        Button(action: { isPresented.toggle() }) {
                            Text("Don't have an account? Sign up")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        Text("or")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 8)
                    
                    // Social Login Section
                    VStack(spacing: 12) {
                        // Sign in with Apple (prioritize this per Apple guidelines)
                        SignInWithAppleButton()
                            .frame(height: 50)
                            .onTapGesture {
                                viewModel.signInWithApple()
                            }
                        
                        // Google Sign In
                        GoogleSignInButton()
                            .frame(height: 50)
                            .onTapGesture {
                                viewModel.signIn()
                            }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .customPopupView(isPresented: $isPresented, popupView: { popupView })
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func setDismissTimer() {
        Task {
            try? await Task.sleep(for: .seconds(3))
            withAnimation(.easeInOut(duration: 0.3)) {
                authenticationDidFail = false
            }
        }
    }
    
    var popupView: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Text("Create Account")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    isPresented.toggle()
                    username = ""
                    password = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Sign up to save your recipes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    UsernameField(username: $username)
                    PasswordField(password: $password)
                    
                    // Status Message
                    if createUserCompleted {
                        if let errorMessage = viewModel.createUserErrorMessage {
                            Label(
                                errorMessage.count < 60 ? errorMessage : "Username and/or password is incomplete.",
                                systemImage: "exclamationmark.triangle.fill"
                            )
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        } else {
                            Label("Successfully created account!", systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Button(action: {
                        viewModel.createUser(username: username, password: password)
                        viewModel.group.notify(queue: .main) {
                            createUserCompleted = true
                        }
                    }) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                username.isEmpty || password.isEmpty ? Color.gray : Color.blue
                            )
                            .cornerRadius(12)
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .frame(maxWidth: 500)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(40)
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

struct TitleText: View {
    var body: some View {
        Text("Going Vegan")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
    }
}

struct LoginIcon: View {
    var body: some View {
        Image("GlobalFruit")
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.green, lineWidth: 4))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct UsernameField: View {
    @Binding var username: String
    
    var body: some View {
        HStack {
            Image(systemName: "envelope.fill")
                .foregroundColor(.gray)
            TextField("Email", text: $username)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct PasswordField: View {
    @Binding var password: String
    
    var body: some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundColor(.gray)
            SecureField("Password", text: $password)
                .textContentType(.password)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SignInButtonText: View {
    var body: some View {
        Text("Sign In")
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .cornerRadius(12)
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


