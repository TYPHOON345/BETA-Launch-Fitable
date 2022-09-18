//
//  SignUpView.swift
//  Fitable
//
//  Created by Kiran Lim on 25/7/22.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseDynamicLinks

struct SignUpView: View {
    @State private var email = ""
    @EnvironmentObject var appState: AppState
    @State private var password = ""
    @State private var username = ""
    
    @State private var showalert = false
    @State private var AlertMessage = ("", "")
    
    @State private var alerttype: alertType = .failure
    @Environment(\.colorScheme) var colorScheme
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("that's weird,my dynamic link object has no url")
            return
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let oobCode = components?.queryItems![2].value
        print("oobCode: \(oobCode!)")
        Auth.auth().applyActionCode(oobCode!, completion: { (err) in

                if err == nil {
                    Auth.auth().currentUser?.reload(completion: {
                            (error) in

                            if(Auth.auth().currentUser?.isEmailVerified)! {

                                print("email verified")
                                Auth.auth().signIn(withEmail: self.email, password: self.password)
                                
                                let joindate = "\(Date.now.formatted(.dateTime.day().month().year()))"
                                
                                let userfile = User(username: self.username, Email: self.email, Joindate: joindate, Userleague: .bronze)
                                try! userdata.realm.write {
                                    userdata.realm.deleteAll()
                                    userdata.realm.add(userfile)
                                }
                                self.showalert = false
                                withAnimation {
                                    self.appState.target = .loggedIn
                                }
                                
                            } else {

                                print("email NOT verified")
                            }
                          })
                }
            })
    }
    
    var user = Auth.auth().currentUser
    var body: some View {
        VStack{
            VStack {
                Text("FITABLE").font(.custom("Gotham-Bold", size: 30)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                Text("SIGN UP").font(.custom("Gotham-Bold", size: 24)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                    .padding(.top, 20)
                
            }
            .padding(.top, 40)
            
            VStack {
                VStack(alignment: .leading) {
                    Text("USERNAME:").font(.custom("Gotham-Bold", size: 24)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                    TextField("", text: $username)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))

                                RoundedRectangle(cornerRadius: 7)
                                .strokeBorder(Color(#colorLiteral(red: 0.8708333373069763, green: 0.8708333373069763, blue: 0.8708333373069763, alpha: 1)), lineWidth: 1)
                            }
                            .frame(width: 250, height: 35)
                            .opacity(0.8)
                        }
                        .frame(width: 250, height: 35)
                        .padding(.top, 5)
                    
                    Text("EMAIL:").font(.custom("Gotham-Bold", size: 24)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                    TextField("", text: $email)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))

                                RoundedRectangle(cornerRadius: 7)
                                .strokeBorder(Color(#colorLiteral(red: 0.8708333373069763, green: 0.8708333373069763, blue: 0.8708333373069763, alpha: 1)), lineWidth: 1)
                            }
                            .frame(width: 250, height: 35)
                            .opacity(0.8)
                        }
                        .frame(width: 250, height: 35)
                        .padding(.top, 5)
                    
                    Text("PASSWORD:").font(.custom("Gotham-Bold", size: 24)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                    TextField("", text: $password)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))

                                RoundedRectangle(cornerRadius: 7)
                                .strokeBorder(Color(#colorLiteral(red: 0.8708333373069763, green: 0.8708333373069763, blue: 0.8708333373069763, alpha: 1)), lineWidth: 1)
                            }
                            .frame(width: 250, height: 35)
                            .opacity(0.8)
                        }
                        .frame(width: 250, height: 35)
                        .padding(.top, 5)
                    
                    Button {
                        if self.email.count > 0 && self.username.count > 0 && self.password.count > 0 {
                        
                            Auth.auth().createUser(withEmail: self.email, password: self.password) { authResult, error in
                        
                                self.appState.email = self.email
                                self.appState.password = self.password
                                self.appState.username = self.username
                                guard error == nil else{
                                    AlertMessage = ("Sign Up Failed", "Error signing up: \(error!.localizedDescription)")
                                    alerttype = .failure
                                    showalert = true
                                    return
                        
                        
                                }
                                alerttype = .success
                                AlertMessage = ("Verify Email", "A link has been sent to the email specified, please open the link to verify your email")
                        
                                showalert = true
                        
                                var actionCodeSettings = ActionCodeSettings.init()
                                actionCodeSettings.handleCodeInApp = true
                                actionCodeSettings.url = URL(string: "https://fitable.page.link/?email=\(self.email)")
                                actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
                        
                        
                                print("the link parameter is \(actionCodeSettings.url)")
                                actionCodeSettings.dynamicLinkDomain = "fitable.page.link"
                                Auth.auth().currentUser?.sendEmailVerification(with: actionCodeSettings) { error in
                                    if error != nil{
                                        print("error sending verification email: \(error!.localizedDescription)")
                                    }
                        
                                }
                        
                        
                        
                        
                            }
                        }

                    }label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                            .frame(width: 250, height: 35)
                            
                            Text("SIGN UP").font(.custom("Gotham-Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 5)
                    .disabled(self.email.count <= 0 && self.username.count <= 0 && self.password.count <= 0)
                    
                    Text("Or").font(.custom("Gotham-Bold", size: 17)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                        .padding(.leading, 135)
                        .padding(.top, 5)
                    
                    Button {
                        let config = GIDConfiguration(clientID: "342162894109-jf2fc1h8l2oe75vj05qn11mipcrhj56h.apps.googleusercontent.com")
                        GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController(), hint: "", additionalScopes: ["https://www.googleapis.com/auth/classroom.coursework.students", "https://www.googleapis.com/auth/classroom.courses","https://www.googleapis.com/auth/classroom.rosters", "https://www.googleapis.com/auth/classroom.coursework.me"]) {user, error in
                            guard error == nil else {
                                print("Sign up failed with error: \(error?.localizedDescription)")
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
                            
                            
                            
                            Auth.auth().signIn(with: credential) {authResult, error in
                                if error != nil {
                                    print("Found an error with Signing Up: \(error?.localizedDescription)")
                                }
                                if error == nil && user!.profile!.email != nil {
                                    self.appState.email = user!.profile!.email
                                    self.appState.target = .GoogleSignIn
                                }
                            }
                            
                        }
                    }label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                            .frame(width: 250, height: 35)
                            
                            Text("SIGN UP USING GOOGLE").font(.custom("Gotham-Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 5)
                    
                    HStack {
                        Text("Already have an account?").font(.custom("Gotham-Bold", size: 13)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                        Button {
                            self.appState.target = .loggedOut
                        }label: {
                            Text("Log In here").font(.custom("Gotham-Bold", size: 13)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                        }
                        
                    }
                    
                    
                }.padding(20)
            }.background {
                customBlurView(effect: colorScheme == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
                    .cornerRadius(15)
            }
            Spacer()
        }
        .background {
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
        .onOpenURL { (url) in
            print("Incoming URL parameter is: \(url)")
            // 2
            let linkHandled = DynamicLinks.dynamicLinks()
              .handleUniversalLink(url) { dynamicLink, error in
              guard error == nil else {
                  print("error handling universal link: \(error?.localizedDescription)")
                  return
              }
              // 3
              if let dynamicLink = dynamicLink {
                // Handle Dynamic Link
                self.handleIncomingDynamicLink(dynamicLink)
              }
            }
            // 4
            if linkHandled {
              print("Link Handled")
            } else {
              print("No Link Handled")
            }
        }
    
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
