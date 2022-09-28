//
//  VerificationView.swift
//  Fitable
//
//  Created by Kiran Lim on 28/7/22.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct VerificationView: View {
    
    @EnvironmentObject var appState: AppState
    @State var Code: [String] = [] {
        mutating didSet{
            self.didtypecode = true
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    var didtypecode = false
    @State var CodeString: String = ""
    @State var showalert: Bool = false
    @State var alerttype: alertType = .failure
    @State var AlertMessage = ("Login verification failed", "You didn't enter a verification code")
    
    @State var shownumberpad = false
        
    @State var iskeyingcode: Bool = false
    var body: some View {
        VStack {
            HStack {
                Button {
                    self.appState.target = .loggedOut
                }label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .foregroundColor(.white)
                }
                .frame(width: 15, height: 25)
                .padding([.leading, .top], 15)
                Spacer()
            }
            
            VStack {
                Text("FITABLE").font(.custom("Gotham-Bold", size: 30)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                Text("ONE TIME PASSWORD").font(.custom("Gotham-Bold", size: 24)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                    .padding(.top, 10)
            }.padding(.top, 15)
            
            VStack {
                VStack(alignment: .leading) {
                    Text("ENTER OTP:").font(.custom("Gotham-Bold", size: 25)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                    HStack(spacing: 20) {
                        if Code.count != 0 {
                            ForEach(Code,id: \.self){i in
                                Text(i).font(.title).fontWeight(.semibold)
                            }
                        }else {
                            Button {
                                withAnimation {
                                    shownumberpad.toggle()
                                }
                            }label: {
                                Text("Click to Enter OTP")
                            }
                        }
                    }
                    .frame(width: 250, height: 50)
                    .onTapGesture {
                        withAnimation {
                            shownumberpad.toggle()
                        }
                    }
                    
                    Button {
                        let hint = self.appState.resolver.hints[0] as! PhoneMultiFactorInfo
                        PhoneAuthProvider.provider().verifyPhoneNumber(
                                  with: hint,
                                  uiDelegate: nil,
                                  multiFactorSession: self.appState.resolver.session) { (verificationId, error) in
                          // verificationId will be needed for sign-in completion.
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                            .frame(width: 250, height: 35)
                            Text("RESEND OTP").font(.custom("Gotham-Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                        }
                    }
                    .frame(width: 250, height: 35)
                    .padding(.top, 5)
                    
                    Button {
                        if CodeString != "" {
                            let credential = PhoneAuthProvider.provider().credential(
                                withVerificationID: self.appState.verificationID!,
                                verificationCode: self.CodeString)
                            let assertion = PhoneMultiFactorGenerator.assertion(with: credential);
                            // Complete sign-in.
                            self.appState.resolver.resolveSignIn(with: assertion) { (authResult, error) in
                                if error == nil {
                                    withAnimation {
                                        self.appState.target = .loggedIn
                                    }
                                    self.AlertMessage = ("Login successful","Welcome back to Fitable")
                                    self.alerttype = .success
                                    self.showalert = true
                                    
                                }
                                if error != nil {
                                    self.AlertMessage = ("Login Verifiation failed", "\(error!.localizedDescription)")
                                    print(self.AlertMessage)
                                    self.alerttype = .failure
                                    self.showalert = true
                                }
                            }
                        }
                        else if didtypecode == false || Code.isEmpty{
                            self.AlertMessage = ("Login Verification Error", "you didn't enter a verification code")
                            self.alerttype = .failure
                            self.showalert = true
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                            .frame(width: 250, height: 35)
                            Text("ENTER").font(.custom("Gotham-Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                        }
                            
                    }
                    .frame(width: 250, height: 50)
                    .padding(.top, 5)
                }
                .padding(20)
            }
            .background {
                customBlurView(effect: colorScheme == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
                    .cornerRadius(15)
            }
            .padding(.top, 20)
            
            if shownumberpad {
                NumberPad(codes: $Code, codeString: $CodeString)
                    .transition(.move(edge: .bottom))
            }
            VStack(spacing: 40) {

                
            }
            Spacer()
            
            
                
        }
        .animation(.spring(), value: Code)
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
        .sheet(isPresented: $showalert) {
            
            AlertView(isshown: $showalert, Title: AlertMessage.0, Message: AlertMessage.1, type:alerttype)
        }
        
    }
}




struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView()
    }
}

struct NumberPad: View {
    
    @Binding var codes : [String]
    @Binding var codeString: String
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(datas) {i in
                
                HStack(spacing: self.getspacing()){
                    
                    ForEach(i.row){j in
                        Button {
                            if j.value == "delete.left.fill" {
                                if self.codes.count > 0 {
                                    self.codes.removeLast()
                                    self.codeString.removeLast()
                                }
                            }
                            else {
                                self.codes.append(j.value)
                                self.codeString += j.value
                            }
                        } label: {
                            if j.value == "delete.left.fill" {
                                Image(systemName: j.value).font(.body).padding(.vertical)
                            }
                            else {
                                Text(j.value)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    
                                
                            }
                        }

                    }
                }
            }
        }.foregroundColor(.white)
    }
    
    func getspacing() -> CGFloat {
        return UIScreen.main.bounds.width / 3
    }
}

struct type: Identifiable {
    var id: Int
    var row: [row]
}

struct row: Identifiable {
    var id: Int
    var value: String
}
var datas = [
type(id: 0, row: [row(id: 0, value: "1"), row(id: 1, value: "2"), row(id: 2, value: "3")]),
type(id: 1, row: [row(id: 0, value: "4"), row(id: 1, value: "5"), row(id: 2, value: "6")]),
type(id: 2, row: [row(id: 0, value: "7"), row(id: 1, value: "8"), row(id: 2, value: "9")]),
type(id: 3, row: [row(id: 0, value: "delete.left.fill"), row(id: 1, value: "0")])
]
