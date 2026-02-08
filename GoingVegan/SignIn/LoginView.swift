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
    @FocusState private var focusedField: Field?
    @State private var isLoading: Bool = false
    
    enum Field: Hashable {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section with Hero Image
                        VStack(spacing: 20) {
                            Spacer()
                                .frame(height: max(60, geometry.safeAreaInsets.top + 20))
                            
                            LoginIcon()
                                .scaleEffect(1.0)
                                .accessibilityLabel("Going Vegan app logo")
                                .accessibilityAddTraits(.isImage)
                            
                            VStack(spacing: 8) {
                                TitleText()
                                    .accessibilityAddTraits(.isHeader)
                                
                                Text("Discover delicious vegan recipes, restaurants, and more")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .accessibilityLabel("Tagline: Discover delicious vegan recipes, restaurants, and more")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                        
                        // Main Content Card
                        VStack(spacing: 24) {
                            // Social Login Section (Prioritized)
                            VStack(spacing: 12) {
                                // Sign in with Apple (prioritize per Apple guidelines)
                                SignInWithAppleButton()
                                    .frame(height: 56)
                                    .cornerRadius(14)
                                    .accessibilityLabel("Sign in with Apple")
                                    .accessibilityHint("Quickly sign in using your Apple ID")
                                    .accessibilityAddTraits(.isButton)
                                    .onTapGesture {
                                        performHapticFeedback()
                                        viewModel.signInWithApple()
                                    }
                                
                                // Google Sign In
                                GoogleSignInButton()
                                    .frame(height: 56)
                                    .cornerRadius(14)
                                    .accessibilityLabel("Sign in with Google")
                                    .accessibilityHint("Quickly sign in using your Google account")
                                    .accessibilityAddTraits(.isButton)
                                    .onTapGesture {
                                        performHapticFeedback()
                                        viewModel.signIn()
                                    }
                            }
                            .accessibilityElement(children: .contain)
                            
                            // Divider
                            HStack(spacing: 16) {
                                Rectangle()
                                    .fill(Color(.separator))
                                    .frame(height: 1)
                                    .accessibilityHidden(true)
                                
                                Text("or continue with email")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary.opacity(0.7))
                                    .fixedSize()
                                    .accessibilityLabel("or continue with email")
                                
                                Rectangle()
                                    .fill(Color(.separator))
                                    .frame(height: 1)
                                    .accessibilityHidden(true)
                            }
                            
                            // Email/Password Login Section
                            VStack(spacing: 16) {
                                UsernameField(username: $username)
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .password
                                    }
                                
                                PasswordField(password: $password)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.go)
                                    .onSubmit {
                                        signInWithEmail()
                                    }
                                
                                // Error Message
                                if authenticationDidFail {
                                    if let errorMessage = viewModel.signInErrorMessage {
                                        ErrorMessageView(message: errorMessage.count < 50 ? errorMessage : "Username and/or password is incorrect.")
                                            .onAppear(perform: setDismissTimer)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                
                                // Sign In Button
                                Button(action: signInWithEmail) {
                                    SignInButtonContent(isLoading: isLoading)
                                }
                                .disabled(username.isEmpty || password.isEmpty || isLoading)
                                .buttonStyle(PrimaryButtonStyle(isEnabled: !username.isEmpty && !password.isEmpty && !isLoading))
                                .accessibilityLabel(isLoading ? "Signing in" : "Sign in with email")
                                .accessibilityHint("Double tap to sign in to your account")
                                .accessibilityAddTraits(.isButton)
                                .accessibilityRemoveTraits(.isImage)
                            }
                            .accessibilityElement(children: .contain)
                            
                            // Create Account Button
                            Button(action: {
                                performHapticFeedback()
                                isPresented.toggle()
                            }) {
                                HStack(spacing: 4) {
                                    Text("Don't have an account?")
                                        .foregroundStyle(.secondary)
                                    Text("Sign up")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.blue)
                                }
                                .font(.subheadline)
                            }
                            .padding(.top, 8)
                            .accessibilityLabel("Create new account")
                            .accessibilityHint("Double tap to create a new Going Vegan account")
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 32)
                        .padding(.bottom, 32)
                        .background(
                            Color(.systemBackground)
                                .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: -8)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(minHeight: 40)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.secondarySystemBackground),
                        Color.green.opacity(0.25)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
        }
        .customPopupView(isPresented: $isPresented, popupView: { popupView })
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func signInWithEmail() {
        performHapticFeedback()
        focusedField = nil
        isLoading = true
        
        viewModel.signInWithEmail(username: username, password: password)
        viewModel.group.notify(queue: .main) {
            isLoading = false
            if viewModel.signInErrorMessage != nil {
                authenticationDidFail = true
                performErrorHaptic()
            }
        }
    }
    
    private func performHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func performErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
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
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button(action: {
                    performHapticFeedback()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented.toggle()
                    }
                    username = ""
                    password = ""
                    createUserCompleted = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                        .symbolRenderingMode(.hierarchical)
                }
                .accessibilityLabel("Close")
                .accessibilityHint("Double tap to close account creation and return to sign in")
            }
            .padding()
            .background(Color(.systemBackground))
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Sign up to save your favorite recipes and track your vegan journey")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    
                    VStack(spacing: 16) {
                        UsernameField(username: $username)
                        PasswordField(password: $password)
                        
                        // Password Requirements
                        if !password.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                PasswordRequirement(
                                    text: "At least 6 characters",
                                    isMet: password.count >= 6
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    // Status Message
                    if createUserCompleted {
                        if let errorMessage = viewModel.createUserErrorMessage {
                            ErrorMessageView(message: errorMessage.count < 60 ? errorMessage : "Username and/or password is incomplete.")
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            SuccessMessageView(message: "Successfully created account!")
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    Button(action: createAccount) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                    .disabled(username.isEmpty || password.isEmpty || password.count < 6)
                    .buttonStyle(PrimaryButtonStyle(isEnabled: !username.isEmpty && !password.isEmpty && password.count >= 6))
                    .accessibilityLabel("Create account")
                    .accessibilityHint("Double tap to create your new Going Vegan account")
                    .accessibilityAddTraits(.isButton)
                    
                    // Terms and Privacy
                    Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .accessibilityLabel("By signing up, you agree to our Terms of Service and Privacy Policy")
                        .accessibilityAddTraits(.isStaticText)
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .frame(maxWidth: 500, maxHeight: 600)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 10)
        .padding(32)
        .transition(.scale.combined(with: .opacity))
    }
    
    private func createAccount() {
        performHapticFeedback()
        viewModel.createUser(username: username, password: password)
        viewModel.group.notify(queue: .main) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                createUserCompleted = true
            }
            if viewModel.createUserErrorMessage != nil {
                performErrorHaptic()
            }
        }
    }
}



// MARK: - Supporting Views

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
    func customPopupView<PopupView>(isPresented: Binding<Bool>, popupView: @escaping () -> PopupView, backgroundColor: Color = .black.opacity(0.5), animation: Animation? = .spring(response: 0.3, dampingFraction: 0.8)) -> some View where PopupView: View {
        return CustomPopupView(isPresented: isPresented, content: { self }, popupView: popupView, backgroundColor: backgroundColor, animation: animation)
    }
}

// MARK: - Title and Logo

struct TitleText: View {
    var body: some View {
        Text("Going Vegan")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [.primary, .green],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .accessibilityLabel("Going Vegan")
    }
}

struct LoginIcon: View {
    var body: some View {
        Image("GlobalFruit")
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
            .shadow(color: .green.opacity(0.3), radius: 20, x: 0, y: 10)
            .accessibilityHidden(true) // Already labeled in the parent view
    }
}

// MARK: - Text Fields

struct UsernameField: View {
    @Binding var username: String
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "envelope.fill")
                .foregroundStyle(.secondary)
                .frame(width: 20)
                .accessibilityHidden(true)
            
            TextField("Email", text: $username)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .accessibilityLabel("Email address")
                .accessibilityValue(username.isEmpty ? "Empty" : username)
                .accessibilityHint("Enter your email address")
        }
        .padding(16)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 1)
        )
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Limit extreme scaling
    }
}

struct PasswordField: View {
    @Binding var password: String
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)
                .frame(width: 20)
                .accessibilityHidden(true)
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .accessibilityLabel("Password")
                .accessibilityValue(password.isEmpty ? "Empty" : "Entered")
                .accessibilityHint("Enter your password")
        }
        .padding(16)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 1)
        )
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Limit extreme scaling
    }
}

// MARK: - Buttons

struct SignInButtonContent: View {
    let isLoading: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.9)
                    .accessibilityLabel("Signing in")
            } else {
                Text("Sign In")
                    .font(.headline)
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    @Environment(\.sizeCategory) var sizeCategory
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isEnabled
                            ? LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [.gray.opacity(0.5), .gray.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .shadow(
                color: isEnabled ? .blue.opacity(0.3) : .clear,
                radius: configuration.isPressed ? 5 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 5
            )
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Prevent overflow
    }
}

// MARK: - Message Views

struct ErrorMessageView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
                .accessibilityHidden(true)
            
            Text(message)
                .font(.caption)
                .multilineTextAlignment(.leading)
        }
        .foregroundColor(.red)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.red.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
        .accessibilityAddTraits(.isStaticText)
    }
}

struct SuccessMessageView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .accessibilityHidden(true)
            
            Text(message)
                .font(.caption)
                .multilineTextAlignment(.leading)
        }
        .foregroundColor(.green)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.green.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.green.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Success: \(message)")
        .accessibilityAddTraits(.isStaticText)
    }
}

struct PasswordRequirement: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isMet ? .green : .secondary)
                .font(.caption)
                .accessibilityHidden(true)
            
            Text(text)
                .font(.caption)
                .foregroundStyle(isMet ? .green : .secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(text): \(isMet ? "met" : "not met")")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationViewModel())
    }
}


