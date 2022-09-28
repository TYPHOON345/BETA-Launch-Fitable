//
//  PoseEstimationView(Workouts).swift
//  Fitable
//
//  Created by Kiran Lim on 13/9/22.
//

import Foundation
import SwiftUI

struct PoseEstimatorWorkoutsView: View {
    
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
                                Text("\(PoseEstimator.shared.currentReps)").font(.custom("Gotham-Bold", size: 25)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
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
            
            
                            }
                        }

            
        }
        .onAppear() {
            PoseEstimator.shared.exerciseType = "Single"
        }
        .onReceive(timer) {time in
            PoseEstimator.shared.timeTotal += 1 / 60
        }
        
        .onAppear() {
            if appState.exerciseType != "Assignment" {
                appState.exerciseType = "Workout"
            }
            
        }
        .onChange(of: PoseEstimator.shared.isdone) { newValue in
            if newValue {
                appState.target = .workoutresults
            }
        }
        .onChange(of: PoseEstimator.shared.isbreak) { newValue in
            if newValue {
                appState.breaktimeleft = "\(PoseEstimator.shared.timeleft)"
                appState.target = .Break
            }
        }
    }
     
}


