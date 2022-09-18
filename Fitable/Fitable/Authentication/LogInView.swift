//
//  LogInView.swift
//  Fitable
//
//  Created by Kiran Lim on 25/7/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn



struct LogInView: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var appState: AppState
    @State var isLoggingIn = false
    @State var alerttype: alertType = .failure
    @State private var error = false
    @State private var AlertError = ("", "")
    
    @Environment(\.colorScheme) var colorScheme
    
    // Ask user which second factor to use.
    var body: some View {
        
        VStack {
            
            VStack {
                Text("FITABLE")
                    .font(.custom("Gotham-Bold", size: 30))
                    .foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                Text("LOGIN")
                    .font(.custom("Gotham-Bold", size: 25))
                    .foregroundColor(.white)
                    .padding(.top, 2)
            }
            .padding(.top, 40)
            
            VStack{
                VStack(alignment: .leading) {
                    Text("EMAIL:")
                        .font(.custom("Gotham-Bold", size: 24))
                        .foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                        
                    
                    TextField("", text: $email)
                        .frame(width: 275, height: 35)
                        .background {
                            RoundedRectangle(cornerRadius: 7)
                            .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))

                            RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(Color(#colorLiteral(red: 0.8708333373069763, green: 0.8708333373069763, blue: 0.8708333373069763, alpha: 1)), lineWidth: 1)
                        }
                    
                    Text("PASSCODE:")
                        .font(.custom("Gotham-Bold", size: 24))
                        .foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                        .padding(.top, 5)
                    
                    SecureField("", text: $password)
                        .frame(width: 275, height: 35)
                        .background {
                            RoundedRectangle(cornerRadius: 7)
                            .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))

                            RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(Color(#colorLiteral(red: 0.8708333373069763, green: 0.8708333373069763, blue: 0.8708333373069763, alpha: 1)), lineWidth: 1)
                        }
                    
                    Button {
                        Task {
                            if self.email.count > 0 && self.password.count > 0 {
                                Auth.auth().signIn(withEmail: email,
                                                    password: password) { (result, error) in
                                    if error != nil {
                                        let authError = error as NSError?
                                        if (authError!.code == AuthErrorCode.secondFactorRequired.rawValue) {
                    
                                            // The user is a multi-factor user. Second factor challenge is required.
                                            let resolver = authError!.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                                            self.appState.resolver = resolver
                                            let hint = resolver.hints[0] as! PhoneMultiFactorInfo
                                            // Send SMS verification code
                                            PhoneAuthProvider.provider().verifyPhoneNumber(
                                                with: hint,
                                                uiDelegate: nil,
                                                multiFactorSession: resolver.session) { (verificationId, error) in
                                                    self.appState.verificationID = verificationId
                                                if error != nil {
                                                    self.AlertError = ("Error sending Verification code", "\(error!.localizedDescription)")
                                                    self.alerttype = .failure
                                                    self.error = true
                                                }
                                                    print("sent phone verification code")
                                                    self.appState.target = .Verification
                                            }
                                            // ...
                                        } else {
                                            self.AlertError = ("Error logging in", "Login failed with error \(error!.localizedDescription)")
                                            self.alerttype = .failure
                                            self.error = true
                                        }
                                    }
                                    if error == nil {
                                        
                                        withAnimation {
                                            self.appState.target = .loggedIn
                                        }
                                    }
                    
                                }
                    
                            } else {
                                print("present view")
                                AlertError = ("Login failed", "you didn't enter an email or password")
                                alerttype = .failure
                                error = true
                            }
                        }
                    } label: {
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                            .frame(width: 275, height: 50)
                            
                            Text("LOGIN").font(.custom("Gotham-Bold", size: 24)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                            
                        }
                        
                    }
                    .sheet(isPresented: $error) {
                        AlertView(isshown: $error, Title: self.AlertError.0, Message: self.AlertError.1, type: .failure)
                    }
                    .padding(.top, 10)
                    
                    Text("Or").font(.custom("Gotham-Bold", size: 17)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                        .padding(.leading, 125)
                        .padding(.vertical, 5)
                    Button {
                        let config = GIDConfiguration(clientID: "342162894109-jf2fc1h8l2oe75vj05qn11mipcrhj56h.apps.googleusercontent.com")
                        GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController(), hint: "", additionalScopes: ["https://www.googleapis.com/auth/classroom.coursework.students", "https://www.googleapis.com/auth/classroom.courses","https://www.googleapis.com/auth/classroom.rosters", "https://www.googleapis.com/auth/classroom.coursework.me"]) {user, error in
                            guard error == nil else {
                                print("Sign in failed with error: \(error?.localizedDescription)")
                                return
                            }
                            guard
                                let authentication = user?.authentication,
                              let idToken = authentication.idToken
                            else {
                              return
                            }
                            
                            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                           accessToken: authentication.accessToken)
                            
                            Auth.auth().signIn(with: credential) { (result, error) in
                                if error != nil {
                                    let authError = error as NSError?
                                    if (authError!.code == AuthErrorCode.secondFactorRequired.rawValue) {
                
                                        // The user is a multi-factor user. Second factor challenge is required.
                                        let resolver = authError!.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                                        self.appState.resolver = resolver
                                        let hint = resolver.hints[0] as! PhoneMultiFactorInfo
                                        // Send SMS verification code
                                        PhoneAuthProvider.provider().verifyPhoneNumber(
                                            with: hint,
                                            uiDelegate: nil,
                                            multiFactorSession: resolver.session) { (verificationId, error) in
                                                self.appState.verificationID = verificationId
                                            if error != nil {
                                                self.AlertError = ("Error sending Verification code", "\(error!.localizedDescription)")
                                                self.alerttype = .failure
                                                self.error = true
                                            }
                                                print("sent phone verification code")
                                                self.appState.target = .Verification
                                        }
                                        // ...
                                    } else {
                                        self.AlertError = ("Error logging in", "Login failed with error \(error!.localizedDescription)")
                                        self.alerttype = .failure
                                        self.error = true
                                    }
                                }
                                if error == nil {
                                    let email = user?.profile?.email ?? ""
                                    let userdatafiles = userdata.realm.objects(User.self).where {
                                        $0.email.starts(with: email)
                                    }
                                    if userdatafiles.count != 0 {
                                        withAnimation {
                                            self.appState.target = .loggedIn
                                        }
                                    }
                                    if userdatafiles.count == 0 {
                                        self.appState.target = .GoogleSignIn
                                        self.appState.email = email
                                    }
                                }
                
                            }
                            
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                            .frame(width: 275, height: 50)
                            
                            Text("LOG IN USING GOOGLE").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                        }
                    }

                    HStack {
                        Text("Don’t have an account yet?").font(.custom("Gotham-Bold", size: 13)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                        Button {
                            self.appState.target = .SignUp
                        }label: {
                            Text("Sign up here").font(.custom("Gotham-Bold", size: 13)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                        }
                        
                    }
                    
                }
                .padding(20)
                
            }.background {
                customBlurView(effect: colorScheme == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
                    .cornerRadius(15)
            }
            .padding(.top, 10)
            Spacer()
        }.background {
            VStack {
                Ellipse()
                    .fill(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(#colorLiteral(red: 0.5647059082984924, green: 0.5647059082984924, blue: 1, alpha: 1)), location: 0.3),
                        .init(color: Color(#colorLiteral(red: 0.5647059082984924, green: 1, blue: 0.7388235926628113, alpha: 1)), location: 1)]),
                            startPoint: UnitPoint(x: 0.32963985933065804, y: -0.04412859199887573),
                            endPoint: UnitPoint(x: 0.5669161533142237, y: 1.1075551175338723)))
                .frame(width: 750, height: 392)
                .rotationEffect(.degrees(-20))
                .offset(x: -50, y: -110)
                Spacer()
                
                Ellipse()
                    .fill(LinearGradient(
                            gradient: Gradient(stops: [
                        .init(color: Color(#colorLiteral(red: 0.5647059082984924, green: 0.5647059082984924, blue: 1, alpha: 1)), location: 0.034237124025821686),
                        .init(color: Color(#colorLiteral(red: 0.5647059082984924, green: 1, blue: 0.7388235926628113, alpha: 1)), location: 1)]),
                            startPoint: UnitPoint(x: 0.5560185248754126, y: -0.15906169507977122),
                            endPoint: UnitPoint(x: 0.5091712737425872, y: 0.8480871423831135)))
                .frame(width: 700, height: 400)
                .rotationEffect(.degrees(-28))
                .offset(x: 0, y: 100)
            }
        }
                
            
            
    }
    
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}

struct customBlurView: UIViewRepresentable {
    var effect: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
    
}
