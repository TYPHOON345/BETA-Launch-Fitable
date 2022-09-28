//
//  ProfileView.swift
//  Fitable
//
//  Created by Kiran Lim on 8/9/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Realm
import GameKit
import GoogleSignIn

struct ProfileView: View {
    @State var userdatafile: User
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    @State var didChangepassword = false
    @State var oldPassword = ""
    @State var newPassword = ""
    @State var confirmNewPassword = ""
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ZStack {
                    Ellipse()
                    .fill(LinearGradient(
                            gradient: Gradient(stops: [
                        .init(color: Color(#colorLiteral(red: 0.5647059082984924, green: 0.5647059082984924, blue: 1, alpha: 1)), location: 0.034237124025821686),
                        .init(color: Color(#colorLiteral(red: 0.5647059082984924, green: 1, blue: 0.7388235926628113, alpha: 1)), location: 1)]),
                            startPoint: UnitPoint(x: 0.5560185248754126, y: -0.15906169507977122),
                            endPoint: UnitPoint(x: 0.6091712737425872, y: 0.7480871423831135)))

                }
                .frame(width: 572, height: 325.6)
                .rotationEffect(.degrees(-180))
                .position(x: 180, y: 615)
            }
            
            VStack {
                Text("Profile").font(.custom("Gotham-Bold", size: 30)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                    .padding(.top, 30)
                Image(uiImage: #imageLiteral(resourceName: "default pfp purple 1"))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipped()
                
                    Text("UserName: \(userdatafile.Username)")
                        .scaledToFit()
                        .font(.custom("Gotham-Bold", size: 25))
                        .foregroundStyle(.linearGradient(Gradient(colors: [Color(hex: "9195FD"), Color(hex: "91E6CC")]), startPoint: .leading, endPoint: .trailing))
                        .background {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                            .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15000000596046448)), radius:4, x:0, y:0)
                        }
                        .padding(.top, 25)
                
                Text("Joined \(userdatafile.joindate)")
                    .font(.custom("Gotham-Bold", size: 20))
                    .foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1))).multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                    .frame(width: 269, height: 150)
                    .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15000000596046448)), radius:4, x:0, y:0)
                    VStack {
                        Button {
                            
                        } label: {
                            Text("Achievements").font(.custom("Gotham Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                            .frame(width: 242, height: 27)
                        }
                        .padding(15)
                        Button {
                            withAnimation {
                                didChangepassword.toggle()
                            }
                        } label: {
                            Text("Change Password").font(.custom("Gotham Regular", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                            .frame(width: 242, height: 27)
                        }
                        
                        Button {
                            do {
                                GIDSignIn.sharedInstance.signOut()
                                try Auth.auth().signOut()
                                self.appState.target = .loggedOut
                            }
                            catch {
                                print("Error Signing out: \(error.localizedDescription)")
                            }
                        } label: {
                            Text("Sign Out").font(.custom("Gotham Regular", size: 16)).foregroundColor(Color(#colorLiteral(red: 0.98, green: 0.99, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 1, green: 0.3500000238418579, blue: 0.3500000238418579, alpha: 1)))
                            .frame(width: 242, height: 27)
                        }
                        .padding(15)

                    }
                    
                }.padding(.top, 50)
                    .frame(width: 269, height: 150)
                
                
                
                Spacer()
                
            }
            .PopUp(Horizontalpadding: 40, show: $didChangepassword, ColorScheme: colorScheme) {
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                didChangepassword.toggle()
                            }
                        }label: {
                            Text("close")
                        }
                        
                        Text("Change Password")
                            .font(.custom("GothamMedium", size: 25))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    
                    VStack(alignment: .leading) {
                        Text("Old Password")
                            .font(.custom("Gotham Regular", size: 20))
                        SecureField("Old Password", text: $oldPassword)
                        Divider()
                    }.padding([.horizontal, .top], 15)
                    
                    VStack(alignment: .leading) {
                        Text("New Password")
                            .font(.custom("Gotham Regular", size: 20))
                        SecureField("New Password", text: $newPassword)
                        Divider()
                    }.padding([.horizontal, .top], 15)
                    
                    VStack(alignment: .leading) {
                        Text("Confirm New Password")
                            .font(.custom("Gotham Regular", size: 20))
                        SecureField("Confirm New Password", text: $confirmNewPassword)
                        Divider()
                    }.padding([.horizontal, .top], 15)
                    
                    Button {
                        guard newPassword == confirmNewPassword else {
                            print("New passwords don't match")
                            return
                        }
                        guard oldPassword == appState.password else {
                            print("old Password doesn't match")
                            return
                        }
                        Auth.auth().currentUser?.updatePassword(to: newPassword) {error in
                            if error != nil {
                                print("updating password failed with error: \(error!.localizedDescription)")
                            }
                            else {
                                print("password updated successfully")
                            }
                        }
                        withAnimation {
                            didChangepassword.toggle()
                        }
                    } label: {
                        Text("Change Password")
                            .font(.custom("GothamMedium", size: 25))
                            .padding(.vertical, 5)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.horizontal, 20)
                            .background {
                                LinearGradient(gradient: Gradient(colors: [Color(hex: "9090FF"), Color(hex: "90FFBC")]), startPoint: .leading, endPoint: .trailing)
                            }
                            .clipShape(Capsule())
                        
                    }
                    .disabled(newPassword == "" || oldPassword == "" || confirmNewPassword == "")

                }
                .frame(width: 360, height: 375, alignment: .center)
                .cornerRadius(15)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(colorScheme == .dark ? Color(.systemGray5) : .white)
                        .shadow(color: Color(.systemGray3), radius: 5, x: 0, y: 5)
                }
            }
        }
    }
}

struct ProfilePreview: PreviewProvider {
    static var previews: some View {
        ProfileView(userdatafile: User())
    }
}
