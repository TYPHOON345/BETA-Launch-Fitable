//
//  AlertView.swift
//  Fitable
//
//  Created by Kiran Lim on 26/7/22.
//

import SwiftUI

enum alertType {
    case success
    case failure
    case networknotification
}

struct AlertView: View {
    @Binding var isshown : Bool
    
    
    @State var Title: String
    @State var Message: String
    @State var type: alertType
    var body: some View {
        VStack{
            switch type {
            case .success:
                Text("Success!").font(.custom("Gotham-Bold", size: 30)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                Image("AppIconUpdated")
                    .resizable()
                    .frame(width: 276, height: 150)
                    .padding(.top, 30)
                
                Text("\(Message)").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                    .frame(width: 276)
                    .padding(.top, 10)
                
                Button {
                    isshown.toggle()
                }label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                        .frame(width: 236, height: 32)
                        //CONTINUE
                        Text("CONTINUE").font(.custom("Gotham Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 10)
                
            case .failure:
                Text("Oops!").font(.custom("Gotham-Bold", size: 30)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                
                Image("AlertViewFailure")
                    .resizable()
                    .frame(width: 276, height: 150)
                    .padding(.top, 30)
                
                Text("\(Message)").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                    .frame(width: 276)
                    .padding(.top, 10)
                
                Button {
                    isshown.toggle()
                }label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                        .frame(width: 236, height: 32)
                        //RETURN
                        Text("RETURN").font(.custom("Gotham Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 10)
                
            case .networknotification:
                Text("You are offline.").font(.custom("Gotham-Bold", size: 30)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                Image("AlertViewFailure")
                    .resizable()
                    .frame(width: 276, height: 150)
                    .padding(.top, 30)
                
                Text("You will be unable to\naccess the marketplace, leaderboard and your data when offline.").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                    .frame(width: 276)
                    .padding(.top, 10)
                
                Button {
                    isshown.toggle()
                }label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                        .frame(width: 250, height: 35)
                        //CONTINUE
                        Text("CONTINUE").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 15)
            }
        }
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(isshown: .constant(false), Title: "Login parameters invalid", Message: "You entered an incorrect email or password", type: .failure)
    }
}
