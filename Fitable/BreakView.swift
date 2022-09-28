//
//  BreakView.swift
//  Fitable
//
//  Created by Kiran Lim on 17/9/22.
//

import Foundation
import SwiftUI


struct BreakView: View {
    @EnvironmentObject var appState: AppState
    @State var breakLength: String
    @State var NextExercise: String = "Squats"
    @State var percentage: CGFloat = 50
    @State var timeleft: CGFloat = 0
    @State var timepassed: CGFloat = 0
    
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack {
            HStack {
                Text("Break")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            ZStack {
                ZStack {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 250, height: 250)
                        .overlay(
                            Circle()
                                .stroke(style: StrokeStyle(lineWidth: 20))
                                .fill(Color.gray.opacity(0.3))
                        )
                }
                ZStack {
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 250, height: 250)
                        .overlay(
                            Circle()
                                .trim(from: 0, to: percentage * 0.01)
                                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                                .fill(AngularGradient(gradient: Gradient(colors: [Color(hex: "9090FF"), Color(hex: "90FFBC")]), center: .center, startAngle: .zero, endAngle: .init(degrees: 360)))
                                .rotationEffect(.init(degrees: -90))
                                
                        ).animation(.spring(), value: percentage)
                }
                
                VStack {
                    Text("Time Left")
                        .font(.title)
                        .fontWeight(.regular)
                    Text("\(Int(timeleft))")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
            }
            .padding(.top, 100)
            
            Text("Next Up: \(NextExercise)")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top, 30)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background() {
            VStack {
                Ellipse()
                  .fill(LinearGradient(gradient: Gradient(stops: [.init(color: Color(hex: "9090FF"), location: 0.00), .init(color: Color(hex: "90FFBC"), location: 1.00)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                  .frame(width: 867, height: 405)
                  .offset(y: -250)
                Spacer()
            }
        }
        .onAppear() {
            timeleft = CGFloat(Int(breakLength)!) * 60
            
        }
        .onReceive(timer) {time in
            if timeleft > 0 {
                timeleft -= 1
                timepassed += 1
                percentage = (timepassed / (CGFloat(Int(breakLength)!) * 60)) * 100
            }
            if timeleft == 0 {
                PoseEstimator.shared.isbreak = false
                withAnimation {
                    appState.target = .Workout
                }
            }
        }
        
        
    }
}
