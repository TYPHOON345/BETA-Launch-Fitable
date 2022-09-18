//
//  GoogleSignUpView.swift
//  Fitable
//
//  Created by Kiran Lim on 9/9/22.
//

import Foundation
import SwiftUI
import Realm


struct GoogleSignUpView: View {
    @State var email = ""
    @State var username = ""
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            VStack {
                Text("FITABLE").font(.custom("Gotham-Bold", size: 30)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center).padding(.top, 50)
                Text("CREATE ACCOUNT").font(.custom("Gotham-Bold", size: 24)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                    .padding(.top, 20)
                
            }
            
            VStack {
                VStack(alignment: .leading) {
                    Text("USERNAME:").font(.custom("Gotham-Bold", size: 24)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                    
                    TextField("", text: self.$username)
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
                        .opacity(0.8)
                    
                    Button {
                        print("executed creation of account")
                        print("Username: \(username), email: \(email)")
                        let joindate = "\(Date.now.formatted(.dateTime.day().month().year()))"

                        let user = User(username: self.username, Email: self.email, Joindate: joindate, Userleague: .bronze)

                        try! userdata.realm.write {
                                userdata.realm.add(user)
                        }

                        withAnimation {
                            self.appState.target = .loggedIn
                        }
                        
                    }label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(LinearGradient(
                                        gradient: Gradient(stops: [
                                    .init(color: Color(#colorLiteral(red: 0.5647059082984924, green: 0.5647059082984924, blue: 1, alpha: 1)), location: 0),
                                    .init(color: Color(#colorLiteral(red: 0.5647059082984924, green: 1, blue: 0.7388235926628113, alpha: 1)), location: 1)]),
                                        startPoint: UnitPoint(x: 0.3283898475944816, y: -0.15625011835337788),
                                        endPoint: UnitPoint(x: 0.5529660907050902, y: 4.562500189414614)))
                            
                            Text("CREATE ACCOUNT").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                        }
                    }
                    .frame(width: 250, height: 50)
                    .padding(.top, 15)
                    
                }
                .padding(20)
            }
            .padding(.top, 30)
            .background {
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
        .onAppear() {
            self.email = self.appState.email
        }
    }
}

struct GoogleSignUpPreview: PreviewProvider {
    static var previews: some View  {
        GoogleSignUpView()
    }
}
