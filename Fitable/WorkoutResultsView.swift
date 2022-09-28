//
//  WorkoutResultsView.swift
//  Fitable
//
//  Created by Kiran Lim on 12/9/22.
//

import Foundation
import SwiftUI
import GoogleSignIn
import FirebaseAuth
import Realm
import GameKit

struct WorkoutResultsView: View {
    
    @EnvironmentObject var appState: AppState
    @State var userdatafile: User = User(username: "", Email: "", Joindate: "", Userleague: .bronze)
    @State var CoinsEarned: Int = 0
    @State var CoinsEntered: Int = 87
    @State var timeprogress: CGFloat = 0
    @State var timeTaken: CGFloat = 0
    @State var totalTime: CGFloat = 0
    
    @State var caloriesprogress: CGFloat = 0.0
    @State var calories: Int = 0
    @State var caloriesGoal:Int = 0
    @State var overallAccuracy: Int = 0
    
    var body: some View {
        VStack {
            
            Text("Workout Results").font(.custom("Gotham-Bold", size: 22)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                .padding(.top, 20)
            
            HStack(spacing: 25) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                        .frame(width: 150, height: 150)
                    .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15000000596046448)), radius:4, x:0, y:4)
                    VStack(spacing: -15) {
                        
                        HStack(spacing: -15) {
                            Text("\(CoinsEarned)").font(.custom("Gotham-Bold", size: 32))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(#colorLiteral(red: 0.5686274766921997, green: 0.8745098114013672, blue: 0.8196078538894653, alpha: 1)), location: 0),
                                        .init(color: Color(#colorLiteral(red: 0.5686274766921997, green: 0.6470588445663452, blue: 0.9529411792755127, alpha: 1)), location: 1)]),
                                    startPoint: UnitPoint(x: 0.5, y: 0),
                                    endPoint: UnitPoint(x: 0.8409090906874646, y: 0.9310345069078899)))
                                .multilineTextAlignment(.trailing)
                            Image(uiImage: #imageLiteral(resourceName: "coin icon 1"))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 33, height: 33)
                                .clipped()
                                .frame(width: 84, height: 84)
                        }
                        Text("Coins\nEarned!").font(.custom("Gotham-Bold", size: 18)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1))).multilineTextAlignment(.center)
                    }
                    .padding(.all, 10)
                    
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                        .frame(width: 150, height: 150)
                    .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15000000596046448)), radius:4, x:0, y:4)
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 15.0)
                                .opacity(0.20)
                                .foregroundColor(Color.gray)
                            Circle()
                                .trim(from: 0.0, to: CGFloat(min(CGFloat(self.overallAccuracy) / 100, 1.0)))
                                .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                                .foregroundStyle(.linearGradient(Gradient(colors: [Color(hex: "9090FF"), Color(hex: "90FFBC")]), startPoint: .bottomTrailing, endPoint: .topLeading))
                                .rotationEffect(Angle(degrees: 270))
                                .animation(.easeInOut(duration: 1.0), value: CGFloat(self.overallAccuracy) / 100)
                        }.padding(.all, 15)
                        
                        VStack {
                            Text("\(self.overallAccuracy)%")
                                .font(.custom("Gotham-Bold", size: 25)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1)))
                            Text("total accuracy").font(.custom("Gotham-Bold", size: 12 )).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1))).multilineTextAlignment(.center)
                        }
                    
                    
                }
                .frame(width: 150, height: 150)
            }
            .padding(.top, 40)
            
            HStack(spacing: 25) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                        .frame(width: 150, height: 150)
                    .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15000000596046448)), radius:4, x:0, y:4)
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 15.0)
                                .opacity(0.20)
                                .foregroundColor(Color.gray)
                            Circle()
                                .trim(from: 0.0, to: CGFloat(min(self.timeprogress, 1.0)))
                                .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                                .foregroundStyle(.linearGradient(Gradient(colors: [Color(hex: "9090FF"), Color(hex: "90FFBC")]), startPoint: .bottomTrailing, endPoint: .topLeading))
                                .rotationEffect(Angle(degrees: 270))
                                .animation(.easeInOut(duration: 1.0), value: self.timeprogress)
                        }.padding(.all, 15)
                        
                        VStack {
                            Text(String(format: "%.1f", timeTaken))
                                .font(.custom("Gotham-Bold", size: 25)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1))) + Text("min").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1)))
                            Text("squatting").font(.custom("Gotham-Bold", size: 13)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1))).multilineTextAlignment(.center)
                        }
                    
                    
                }
                .frame(width: 150, height: 150)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                        .frame(width: 150, height: 150)
                    .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15000000596046448)), radius:4, x:0, y:4)
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 15.0)
                                .opacity(0.20)
                                .foregroundColor(Color.gray)
                            Circle()
                                .trim(from: 0.0, to: CGFloat(min(self.caloriesprogress, 1.0)))
                                .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                                .foregroundStyle(.linearGradient(Gradient(colors: [Color(hex: "9090FF"), Color(hex: "90FFBC")]), startPoint: .bottomTrailing, endPoint: .topLeading))
                                .rotationEffect(Angle(degrees: 270))
                                .animation(.easeInOut(duration: 1.0), value: self.caloriesprogress)
                        }.padding(.all, 15)
                        
                        VStack {
                            Text("\(calories)")
                                .font(.custom("Gotham-Bold", size: 25)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1))) + Text("cal").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1)))
                            Text("burnt").font(.custom("Gotham-Bold", size: 15)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1))).multilineTextAlignment(.center)
                        }
                    
                    
                }
                .frame(width: 150, height: 150)
            }
            .padding(.top, 5)
            
            Button {
                withAnimation {
                    self.appState.target = .loggedIn
                }
            }label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5.45)
                        .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                    .frame(width: 205, height: 39)
                    
                    Text("HOME").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                }
            }
            .frame(width: 250, height: 47)
            .padding(.top, 40)
            Spacer()
        }
        .background() {
            VStack {
                Spacer()
                Ellipse()
                    .fill(LinearGradient(
                            gradient: Gradient(stops: [
                        .init(color: Color(#colorLiteral(red: 0.5647059082984924, green: 0.5647059082984924, blue: 1, alpha: 1)), location: 0.034237124025821686),
                        .init(color: Color(#colorLiteral(red: 0.5647059082984924, green: 1, blue: 0.7388235926628113, alpha: 1)), location: 1)]),
                            startPoint: UnitPoint(x: 0.5560185248754126, y: -0.15906169507977122),
                            endPoint: UnitPoint(x: 0.6091712737425872, y: 0.7480871423831135)))
                .frame(width: 572, height: 325.6)
                .rotationEffect(.degrees(-180))
                .offset(y: 140)
            }
        }
        .onAppear() {
            let email = Auth.auth().currentUser?.email ?? ""
            let userdatafiles = userdata.realm.objects(User.self).where {
                $0.email.starts(with: email)
            }
            if userdatafiles.count != 0 {
                userdatafile = userdatafiles.first!
            }
            if PoseEstimator.shared.exerciseType == "Single" {
                
                let currentExercise = PoseEstimator.shared.chosenExercise == "Squats" ? PoseEstimator.shared.squatCount :  PoseEstimator.shared.chosenExercise == "Jumping Jacks" ? PoseEstimator.shared.JumpingJackCounter : PoseEstimator.shared.chosenExercise == "Pushups" ? PoseEstimator.shared.PushupCounter : PoseEstimator.shared.chosenExercise == "Burpees" ? PoseEstimator.shared.BurpeesCounter : PoseEstimator.shared.SLDeadliftsCounter
                
                if PoseEstimator.shared.currentaccuracy != 0 {
                    overallAccuracy = Int((CGFloat(PoseEstimator.shared.currentaccuracy) / CGFloat(currentExercise)) * 100)
                }
                timeTaken = round((CGFloat(currentExercise) * (2 / 60)) * 10000) / 10000
                print("time taken: \(timeTaken), currentExercise: \(currentExercise)")
                totalTime = PoseEstimator.shared.timeTotal

                timeprogress = timeTaken / totalTime
                calories = Int(0.175 * 8 * 54 * timeTaken)
                caloriesGoal = userdatafile.caloriesgoal
                caloriesprogress = CGFloat(calories) / CGFloat(caloriesGoal)

                CoinsEntered = calories * 2


                try! userdata.realm.write {
                    userdatafile.currentDay?.calories += calories
                    userdatafile.WeeklyCalories += calories
                    let exerciseIndex = userdatafile.currentDay?.exercises.firstIndex(where: {$0.name == PoseEstimator.shared.chosenExercise}) ?? nil
                    if exerciseIndex != nil {
                        userdatafile.currentDay?.exercises[exerciseIndex!].timespent += Float(timeTaken)
                    }
                    else if exerciseIndex == nil {
                        userdatafile.currentDay?.exercises.append(Exercise(name: PoseEstimator.shared.chosenExercise, iconimgName: PoseEstimator.shared.currentexercise, fullsizeImgName: "\(PoseEstimator.shared.currentexercise) icon img", exerciseType: .cardio))
                        userdatafile.currentDay?.exercises.last?.timespent += Float(timeTaken)
                    }
                    userdatafile.currentDay?.calorieshour.last?.calories += calories
                }
            }
            if PoseEstimator.shared.exerciseType == "Workout" {
                overallAccuracy = PoseEstimator.shared.overallaccuracy
                for (index, rep) in PoseEstimator.shared.reps.enumerated() {
                    timeTaken += CGFloat(Int(rep)!) * 2
                    let exerciseIndex = userdatafile.currentDay?.exercises.firstIndex(where: {$0.name == PoseEstimator.shared.Exercises[index]}) ?? nil
                    if exerciseIndex != nil {
                        userdatafile.currentDay?.exercises[exerciseIndex!].timespent += Float(timeTaken)
                    }
                    else if exerciseIndex == nil {
                        userdatafile.currentDay?.exercises.append(Exercise(name: PoseEstimator.shared.chosenExercise, iconimgName: PoseEstimator.shared.currentexercise, fullsizeImgName: "\(PoseEstimator.shared.currentexercise) icon img", exerciseType: .cardio))
                    }
                }
                totalTime = PoseEstimator.shared.timeTotal

                timeprogress = timeTaken / totalTime
                calories = Int(0.175 * 8 * 54 * timeTaken)
                caloriesGoal = userdatafile.caloriesgoal
                caloriesprogress = CGFloat(calories) / CGFloat(caloriesGoal)

                CoinsEntered = calories * 2

                try! userdata.realm.write {
                    userdatafile.currentDay?.calories += calories
                    userdatafile.WeeklyCalories += calories
                    userdatafile.currentDay?.calorieshour.last?.calories += calories
                }
            }

            if PoseEstimator.shared.exerciseType == "Assignment" {
                overallAccuracy = PoseEstimator.shared.overallaccuracy
                for (index, rep) in PoseEstimator.shared.reps.enumerated() {
                    timeTaken += CGFloat(Int(rep)!) * 2
                    let exerciseIndex = userdatafile.currentDay?.exercises.firstIndex(where: {$0.name == PoseEstimator.shared.Exercises[index]}) ?? nil
                    if exerciseIndex != nil {
                        userdatafile.currentDay?.exercises[exerciseIndex!].timespent += Float(timeTaken)
                    }
                    else if exerciseIndex == nil {
                        userdatafile.currentDay?.exercises.append(Exercise(name: PoseEstimator.shared.chosenExercise, iconimgName: PoseEstimator.shared.currentexercise, fullsizeImgName: "\(PoseEstimator.shared.currentexercise) icon img", exerciseType: .cardio))
                    }
                }
                totalTime = PoseEstimator.shared.timeTotal

                timeprogress = timeTaken / totalTime
                calories = Int(0.175 * 8 * 54 * timeTaken)
                caloriesGoal = userdatafile.caloriesgoal
                caloriesprogress = CGFloat(calories) / CGFloat(caloriesGoal)

                CoinsEntered = calories * 2

                try! userdata.realm.write {
                    userdatafile.currentDay?.calories += calories
                    userdatafile.WeeklyCalories += calories
                    userdatafile.currentDay?.calorieshour.last?.calories += calories
                }

                GIDSignIn.sharedInstance.restorePreviousSignIn() {user, error in
                    let studentName = user?.profile?.name
                    SubmitAssignment(CourseWorkID: appState.CourseWorkID, CourseID: appState.CourseID, WorkoutExercises: PoseEstimator.shared.Exercises, ExerciseAccuracy: PoseEstimator.shared.exericseaccuracy, Comments: PoseEstimator.shared.comments, StudentName: studentName!, workoutAccuracy: "\(PoseEstimator.shared.overallaccuracy)", comments: PoseEstimator.shared.comments)
                    print("Submission made to course: \(appState.CourseID)")
                }
            }
            
            GKLeaderboard.submitScore(userdatafile.WeeklyCalories, context: 0, player: GKLocalPlayer.local, leaderboardIDs: ["WeeklyHighScore"]) { error in
                if error != nil {
                    print("Error submitting score: \(error?.localizedDescription)")
                }
            }

            if CoinsEarned != 0 {
                addNumberWithRollingAnimation()
            }
        }
    }
    func addNumberWithRollingAnimation() {
        withAnimation {
            // Decide on the number of animation steps
            let animationDuration = 1000 // milliseconds
            let steps = min(abs(CoinsEntered), 100)
            let stepDuration = (animationDuration / steps)
            
            // add the remainder of our entered num from the steps
            CoinsEarned += CoinsEntered % steps
            // For each step
            (0..<steps).forEach { step in
                // create the period of time when we want to update the number
                // I chose to run the animation over a second
                let updateTimeInterval = DispatchTimeInterval.milliseconds(step * stepDuration)
                let deadline = DispatchTime.now() + updateTimeInterval
                
                // tell dispatch queue to run task after the deadline
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    // Add piece of the entire entered number to our total
                    self.CoinsEarned += Int(CoinsEntered / steps)
                }
            }
        }
    }
}

