//
//  PoseEstimationView.swift
//  Fitable
//
//  Created by Kiran Lim on 12/9/22.
//

import Foundation
import SwiftUI

struct PoseEstimatorView: View {
    
    @ObservedObject var poseEstimator = PoseEstimator()
    @State var didpause = false
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geometry in
                    CameraViewWrapper(poseEstimator: poseEstimator)
                    StickFigureView(poseEstimator: poseEstimator, size: geometry.size)
                    dotview(poseEstimator: poseEstimator, size: geometry.size)
                    correctionsview(poseEstimator: poseEstimator, size: geometry.size)
                }
                VStack {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                .frame(width: 80, height: 48)
                                .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)), radius:7, x:0, y:4)
                                Text("\(PoseEstimator.shared.chosenExercise == "Squats" ? PoseEstimator.shared.squatCount :  PoseEstimator.shared.chosenExercise == "Jumping Jacks" ? PoseEstimator.shared.JumpingJackCounter : PoseEstimator.shared.chosenExercise == "Push Ups" ? PoseEstimator.shared.PushupCounter : PoseEstimator.shared.chosenExercise == "Burpees" ? PoseEstimator.shared.BurpeesCounter : PoseEstimator.shared.SLDeadliftsCounter)").font(.custom("Gotham-Bold", size: 25)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                            }
                            .padding(.leading, 15)
                            .padding(.top, 15)
                            Spacer()
                        }
                        Spacer()
                    }
            }.aspectRatio(1080 / 1920, contentMode: .fit)
            
            ZStack {
            
                            HStack {
                                Button {
                                    poseEstimator.pause.toggle()
                                }label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5.45)
                                            .fill(Color(#colorLiteral(red: 1, green: 0.3490196168422699, blue: 0.3490196168422699, alpha: 1)))
                                        .frame(width: 136, height: 32)
                                        HStack {
                                            Image(systemName: "pause.fill")
                                                .resizable()
                                                .foregroundColor(.white)
                                                .frame(width:20, height: 20)
                                            //Pause
                                            Text("Pause").font(.custom("Gotham-Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                                        }
                                    }
                                }
            
                                Spacer()
                                    .frame(width: 20)
                                Button {
                                    poseEstimator.pause = false
                                    appState.target = .workoutresults
                                }label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5.45)
                                            .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                                        .frame(width: 136, height: 32)
            
                                        //Finish
                                        Text("Finish").font(.custom("Gotham-Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                                    }
                                }
                                .frame(width: 136, height: 32)
            
                            }
                        }

            
        }
        .onAppear() {
            appState.exerciseType = "Single"
        }
        .onReceive(timer) {time in
            appState.TimeTotal += 1/60
        }
    }
}



