//
//  ContentView.swift
//  Fitable
//
//  Created by Kiran Lim on 24/7/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseDynamicLinks


struct ContentView: View {
    @StateObject var appState = AppState()
    private var authListener: AuthStateDidChangeListenerHandle?
    
    
    var body: some View {
        

        Group {
            if self.appState.target == .loggedOut {
                LogInView()
                    .transition(.move(edge: .leading))
            } else if self.appState.target == .loggedIn {
                HomeView()
                    .transition(.move(edge: .leading))
            }
            else if self.appState.target == .GoogleSignIn {
                GoogleSignUpView()
                    .transition(.move(edge: .leading))
                
            }
            else if self.appState.target == .SignUp {
                SignUpView()
                    .transition(.move(edge: .leading))
            }
            else if self.appState.target == .Verification {
                VerificationView()
                    .transition(.move(edge: .leading))
            }
            else if self.appState.target == .PoseEstimation {
                PoseEstimatorView()
                    .transition(.move(edge: .leading))
            }
            else if self.appState.target == .workoutresults {
                WorkoutResultsView()
                    .transition(.move(edge: .leading))
            }
            else if self.appState.target == .Workout {
                PoseEstimatorWorkoutsView()
                    .transition(.move(edge: .leading))
            }
        }
        .environmentObject(appState)
        .onAppear(){
            self.appState.listen()
            if let userInfo = Auth.auth().currentUser {
                        userInfo.reload(completion: { (error) in
                            guard error == nil else {
                                if error!._code == 17011 {
                                    withAnimation {
                                        self.appState.target = .loggedOut
                                    }
                                }
                                return
                            }
                        })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
