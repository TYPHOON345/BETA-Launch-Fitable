//
//  PoseEstimation.swift
//  Fitable
//
//  Created by Kiran Lim on 28/8/21.
//

import Foundation  //importing all necessary things for real time pose esimation
import AVFoundation
import Vision
import Combine
import SwiftUI

//declaring PoseEstimator as a class. We need to add AVCaptureVideoDataOutputSampleBufferDelegate and make it an obserable object to use PoseEsimation on our AVFoundation video output
@available(iOS 15.0, *)
class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    
    @Published var chosenExercise: String = ""
    @Published var Exercises: [String] = []
    @Published var reps: [String] = []
    @Published var pause: Bool = false
    @Published var isBreak: Bool = false
    @Published var totalbreaktime: Int = 0
    @Published var timeleft: Int = 0
    @Published var breakprogress = 0
    @Published var overallaccuracy = 100
    @Published var exericseaccuracy: [String] = []
    var currentaccuracy = 100
    @Published var comments: [String] = []
    let sequenceHandler = VNSequenceRequestHandler()
    @Published var bodyParts = [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]() //declare body parts as a published variable storing the coordinates of the body joints from Vision
    
    static let shared = PoseEstimator()
    
    var seconds = 0 //This variable will hold a starting value of seconds. It could be any amount above 0.
    
    var timer: Timer = Timer()
    
    var isTimerRunning = false//This will be used to make sure only one timer is created at a time.
    
    
    var elaspedTime = Float()//we need it to declare it as a float because we would be storing numbers with decimals inside//This one is for Planks the one above is to fix a lunge bug
    var halfburpee = 0
    var halfLunge = 0
    var halfPU = 0
    var uprightLunge = false
    var wasInBottomPosition = false       //declare the position of the player as top or bottom
    var wasInBottomLunge = false
    var wasInTopJJ = false
    var wasInBottomPU = false
    var wasInDeadLift = false
    var wasInMidBurpee = false
    var wasInBottomBurpee = false
    var wasinupright = false
    var wasinalmostdoneBurpee = false
    var down = false
    var cooldown = true
    
    //variables for workouts
    var totalreps = 0
    var repscorrect = 0
    var isworkout = false
    var currentexercise = ""
    var currentReps = 0
    var totalworkoutcaloriesburnt = Float()
    var index = 0
    @State var isbreak = false
    var isdone = false
    @Published public var shortbreak = false
    @Published public var longbreak = false
    
    @Published var squatdisplay = ""
    @Published var JJdisplay = ""
    @Published var PUdisplay = ""
    @Published var Burpeedisplay = ""
    @Published var SLDdisplay = ""
    
    @Published var squatCount = 0          //declare variables for no of exercises done
    @Published var LungeCounter = 0
    @Published var JumpingJackCounter = 0
    @Published var PushupCounter = 0
    @Published var BurpeesCounter = 0
    @Published var SLDeadliftsCounter = 0
    @Published var isGoodSquatPosture = true
    @Published var isGoodLungePosture = true
    @Published var isGoodJJPosture = true
    @Published var isGoodPUPosture = true
    @Published var isGoodSLDPosture = true
    @Published var caloriesburntSquats = Float()
    @Published var caloriesBurntJJ = Float()
    @Published var caloriesBurntPushUps = Float()
    @Published var caloriesBurntSLD = Float()
    @Published var caloriesBurntBurpees = Float()
    
    
    @Published var rightanklecolor = Color.cyan
    @Published var rightkneecolor = Color.cyan
    @Published var righthipcolor = Color.cyan
    
    @Published var leftanklecolor = Color.cyan
    @Published var leftkneecolor = Color.cyan
    @Published var lefthipcolor = Color.cyan
    
    @Published var rightwristcolor = Color.cyan
    @Published var rightelbowcolor = Color.cyan
    @Published var rightshouldercolor = Color.cyan
    
    @Published var leftwristcolor = Color.cyan
    @Published var leftelbowcolor = Color.cyan
    @Published var leftshouldercolor = Color.cyan
    
    @Published var rootcolor = Color.cyan
    @Published var neckcolor = Color.cyan
    
    @Published var error = "No Error"
    @Published var wholebodyshown = false
    
    @Published var rightheelheight: CGFloat = 0
    @Published var leftheelheight: CGFloat = 0
    
    @Published var rightshoulderheight: CGFloat = 0
    @Published var leftshoulderheight: CGFloat = 0
    
    @Published var phoneonwhichside = ""
    @Published var frontheel: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @Published var frontknee: CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    @Published var backheel: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @Published var backknee: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @Published var begin = false
    @Published var starttimer = false
        
    
    
    
    
    var rightwristlocaiton = CGPoint()
    var rightelbowlocation = CGPoint()
    var rightshoulderlocation = CGPoint()
    var necklocation = CGPoint()
    var leftwristlocation = CGPoint()
    var leftelbowlocation = CGPoint()
    @Published var leftshoulderlocation = CGPoint()
    var rootlocation = CGPoint()
    var rightanklelocation = CGPoint()
    var rightkneelocation = CGPoint()
    var righthiplocation = CGPoint()
    var leftanklelocation = CGPoint()
    var leftkneelocation = CGPoint()
    var lefthiplocation = CGPoint()
    
    var timerran = false
    
    var isuprightsquats = true
    var imageorientation = CGImagePropertyOrientation.right
    
    
    var subscriptions = Set<AnyCancellable>()        //for combine to store the proessed coordinates of Vision
    
    override init() {
        super.init()
        timer.invalidate()
        $bodyParts
            .dropFirst()
            .sink(receiveValue: { bodyParts in self.Process(bodyParts: bodyParts)})
            .store(in: &subscriptions)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectedBodyPose)
        do {
            try sequenceHandler.perform(            //sent request to detect human body joints from AVFoundation
              [humanBodyRequest],
              on: sampleBuffer,
              orientation: PoseEstimator.shared.imageorientation)
        } catch {
          print(error.localizedDescription)
        }
    }
    func detectedBodyPose(request: VNRequest, error: Error?) {
        guard let bodyPoseResults = request.results as? [VNHumanBodyPoseObservation]       //set bodyPoseResults as the the reuslts from Vision
          else { return }
        guard let bodyParts = try? bodyPoseResults.first?.recognizedPoints(.all) else { return }
        DispatchQueue.main.async {
            self.bodyParts = bodyParts//set bodyparts as the recognised points from vision
            
        }
    }
    
    func Process(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) { // function for processing results from vision
        
        
        
        
        let rightKnee = bodyParts[.rightKnee]!.location  // declare variables that we need to determine if the player is doing exercise
        let leftKnee = bodyParts[.leftKnee]!.location
        let rightHip = bodyParts[.rightHip]!.location
        let rightAnkle = bodyParts[.rightAnkle]!.location
        let leftAnkle = bodyParts[.leftAnkle]!.location
        let leftHip = bodyParts[.leftHip]!.location
        let rightShoulder = bodyParts[.rightShoulder]!.location
        let leftShoulder = bodyParts[.leftShoulder]!.location
        let rightElbow = bodyParts[.rightElbow]!.location
        let leftElbow = bodyParts[.leftElbow]!.location
        let rightWrist = bodyParts[.rightWrist]!.location
        let leftWrist = bodyParts[.leftWrist]!.location
        let root = bodyParts[.root]!.location
        let neck = bodyParts[.neck]!.location
        
        //squats angles decleration
        let firstAngle = atan2(rightHip.y - rightKnee.y, rightHip.x - rightKnee.x) // simple trigonometry to determine the angles required
        let secondAngle = atan2(rightAnkle.y - rightKnee.y, rightAnkle.x - rightKnee.x)
        var angleDiffRadians = firstAngle - secondAngle //calculate the difference between the angles
        
        //Jumping Jacks angles decleration
        let firstJJAngle = atan2(rightHip.y - rightShoulder.y, rightHip.x - rightShoulder.x)
        let secondJJAngle = atan2(rightElbow.y - rightShoulder.y, rightElbow.x - rightShoulder.x) //calculate angles of armpit
        var JJangleDiffRadians = firstJJAngle - secondJJAngle
        
        let firstrootAngle = atan2(rightKnee.y - root.y, rightKnee.x - root.x)
        let secondrootAngle = atan2(leftKnee.y - root.y, leftKnee.x - root.x)
        var rootangleDiffRadians = firstrootAngle + secondrootAngle
        
        //Pushups anlges decleration
        let firstPUAngle = atan2(rightShoulder.y - rightElbow.y, rightShoulder.x - rightElbow.x)
        let secondPUAngle = atan2(rightWrist.y - rightElbow.y, rightWrist.x - rightElbow.x)
        var PUAngleDiffRadians = firstPUAngle - secondPUAngle
        
        //SLDeadlifts angles decleration
        let firstDeadliftAngle = atan2(neck.y - root.y, neck.x - root.x)
        let secondDeadLiftAngle = atan2(rightKnee.y - root.y, rightKnee.x - root.x)
        var SLDangleDiffRadians = firstDeadliftAngle - secondDeadLiftAngle
        
        let firstLegAngle = atan2(leftAnkle.y - leftKnee.y, leftAnkle.x - leftKnee.x)
        let secondLegAngle = atan2(leftHip.y - leftKnee.y, leftHip.x - leftKnee.x)
        var legAngleDiffRadians = firstLegAngle - secondLegAngle
        
        //Burpees angles decleration
        let firstBurpeeAngle = atan2(rightElbow.y - rightShoulder.y, rightElbow.x - rightShoulder.x)
        let secondBurpeeAngle = atan2(neck.y - rightShoulder.y, neck.x - rightShoulder.x)
        var BurpeeAngleDiffRadians = firstBurpeeAngle - secondBurpeeAngle
        
        //conversion of angles in radians to degrees
        while angleDiffRadians < 0 {
                    angleDiffRadians += CGFloat(2 * Double.pi)
                }
        while JJangleDiffRadians < 0{
            JJangleDiffRadians += CGFloat(2 * Double.pi)
        }
        while rootangleDiffRadians < 0{
            rootangleDiffRadians += CGFloat(2 * Double.pi)
        }
        while PUAngleDiffRadians < 0{
            PUAngleDiffRadians += CGFloat(2 * Double.pi)
        }
        while SLDangleDiffRadians < 0{
            SLDangleDiffRadians += CGFloat(2 * Double.pi)
        }
        while legAngleDiffRadians < 0{
            legAngleDiffRadians += CGFloat(2 * Double.pi)
        }
        while BurpeeAngleDiffRadians < 0{
            BurpeeAngleDiffRadians += CGFloat(2 * Double.pi)
        }
        
        
        let angleDiffDegrees = Int(angleDiffRadians * 180 / .pi)

        let rootangleDIffDegrees = Int(rootangleDiffRadians * 180 / .pi)
        let JJangleDIffDegrees = Int(JJangleDiffRadians * 180 / .pi)
        
        let PUAngleDiffDegrees = Int(PUAngleDiffRadians * 180 / .pi)
        let SLDAngleDiffDegrees = Int(SLDangleDiffRadians * 180 / .pi)
        let legAngleDiffDegrees = Int(legAngleDiffRadians * 180 / .pi)
        let BurpeeAngleDiffDegrees = Int(BurpeeAngleDiffRadians * 180 / .pi)
        
        
        
        let hipHeight = rightHip.y
        let lefthipHeight = leftHip.y
        let kneeHeight = rightKnee.y
        let leftkneeHeight = leftKnee.y
        let ankleheight = rightAnkle.y
        let leftankleheight = leftAnkle.y
        let shoulderheight = rightShoulder.y
        let elbowHeight = rightElbow.y
        let wristheight = leftWrist.y
        
        let kneeDistance = rightKnee.distance(to: leftKnee)
        let ankleDistance = rightAnkle.distance(to: leftAnkle)
        let wristDistance = rightWrist.distance(to: leftWrist)
        let shoulderDistance = rightShoulder.distance(to: leftShoulder)
        if !pause {
            switch PoseEstimator.shared.chosenExercise{
            case "Squats":
                //process whether the player is doing a squat
                print(angleDiffDegrees)
                print("begin \(self.begin)")
                if angleDiffDegrees > 150 && self.wasInBottomPosition == true &&  PoseEstimator.shared.isworkout == false && self.wholebodyshown == true{ // determine if the player is doing a squat
                    if self.isGoodSquatPosture {
                        PoseEstimator.shared.currentaccuracy += 1
                    }
                    self.wasInBottomPosition = false
                    PoseEstimator.shared.squatCount += 1
                    print(PoseEstimator.shared.squatCount)
                    PoseEstimator.shared.caloriesburntSquats = Float(PoseEstimator.shared.squatCount) * 0.32
                }
                if angleDiffDegrees > 150 && self.wholebodyshown == true && self.begin == true{
                    self.error = "No Error"
                    rightkneecolor = Color.cyan
                    leftkneecolor = Color.cyan
                }
                if angleDiffDegrees > 150 && self.wasInBottomPosition == true && PoseEstimator.shared.isworkout == true && PoseEstimator.shared.isbreak == false && self.wholebodyshown == true{
                    if self.isGoodSquatPosture {
                        PoseEstimator.shared.currentaccuracy += 1
                    }
                    self.wasInBottomPosition = false
                    PoseEstimator.shared.currentReps -= 1
                    PoseEstimator.shared.totalreps += 1
                    print("squats left: \(PoseEstimator.shared.currentReps)")
                    PoseEstimator.shared.totalworkoutcaloriesburnt += 0.32
                }
                
                if hipHeight < kneeHeight { //determing if the user is in the bottom position of the squat
                    self.wasInBottomPosition = true
                }
                print("was in bottom position: \(self.wasInBottomPosition), \(PoseEstimator.shared.isworkout), \(PoseEstimator.shared.isbreak), \(self.wholebodyshown)")
                
                
                
                
                //posture check for squats
                if rightAnkle != CGPoint(x: 0.0, y: 1.0) && leftAnkle != CGPoint(x: 0.0, y: 1.0) && rightKnee != CGPoint(x: 0.0, y: 1.0) && leftKnee != CGPoint(x: 0.0, y: 1.0) && rightHip != CGPoint(x: 0.0, y: 1.0)
                    && leftHip != CGPoint(x: 0.0, y: 1.0) && root != CGPoint(x: 0.0, y: 1.0) && neck != CGPoint(x: 0.0, y: 1.0) && rightShoulder != CGPoint(x: 0.0, y: 1.0)
                    && leftShoulder != CGPoint(x: 0.0, y: 1.0)
                    && leftElbow != CGPoint(x: 0.0, y: 1.0)
                    && rightElbow != CGPoint(x: 0.0, y: 1.0)
                    && leftWrist != CGPoint(x: 0.0, y: 1.0)
                    && rightWrist != CGPoint(x: 0.0, y: 1.0){
                    self.wholebodyshown = true
                    self.error = "no error"
                }
                if rightAnkle == CGPoint(x: 0.0, y: 1.0) || leftAnkle == CGPoint(x: 0.0, y: 1.0) || rightKnee == CGPoint(x: 0.0, y: 1.0) || leftKnee == CGPoint(x: 0.0, y: 1.0) || rightHip == CGPoint(x: 0.0, y: 1.0)
                            || leftHip == CGPoint(x: 0.0, y: 1.0) || root == CGPoint(x: 0.0, y: 1.0) || neck == CGPoint(x: 0.0, y: 1.0) || rightShoulder == CGPoint(x: 0.0, y: 1.0)
                            || leftShoulder == CGPoint(x: 0.0, y: 1.0)
                            || leftElbow == CGPoint(x: 0.0, y: 1.0)
                            || rightElbow == CGPoint(x: 0.0, y: 1.0)
                            || leftWrist == CGPoint(x: 0.0, y: 1.0)
                            || rightWrist == CGPoint(x: 0.0, y: 1.0){
                    self.wholebodyshown = false
                    self.error = "wholebodyisntinframe"
                }
                
                
                if shoulderDistance...(shoulderDistance + 0.2) ~= ankleDistance && self.wholebodyshown == true{ //checking if the posture of the player doing squats is good
                    print("ankle: \(ankleDistance)")
                    print(shoulderDistance + 0.2)
                    isGoodSquatPosture = true
                    rightanklecolor = Color.cyan
                    leftanklecolor = Color.cyan
                    if self.timerran == false {
                        self.timerran = true
                        self.timer.invalidate()
                        self.error = "readytobegin"
                        self.starttimer = true
                        self.begin = true
                    }
                    
                    
                }
                if self.wholebodyshown == true && !(shoulderDistance...(shoulderDistance + 0.20) ~= ankleDistance){
                    print("stancetoowideornarrow")
                    isGoodSquatPosture = false
                    rightanklecolor = Color.red
                    leftanklecolor = Color.red
                    self.error = "stancetoowideornarrow"
                }
                
                
                if kneeDistance < ankleDistance && self.wholebodyshown == true && self.begin == true{
                    isGoodSquatPosture = false
                    print("kneesdonttrackoverfeet")
                    self.error = "kneesdonttrackoverfeet"
                    
                    rightkneecolor = Color.red
                    leftkneecolor = Color.red
                    
                }
                if kneeDistance > ankleDistance && self.wholebodyshown == true && self.begin == true{
                    self.error = "No Error"
                    rightkneecolor = Color.cyan
                    leftkneecolor = Color.cyan
                }
                
                if self.begin == true && self.wholebodyshown == true && self.wasInBottomPosition == true && (kneeHeight > self.rightheelheight || leftankleheight > self.leftheelheight) {
                    self.error = "you get up on your toes"
                    isGoodSquatPosture = false
                    rightanklecolor = Color.red
                    rightanklecolor = Color.red
                }
                
                else{
                    isGoodSquatPosture = false
                }
                
                //process whether the player is doing a lunge
                
                
                
                
                
                
                
            case "Jumping Jacks":
                //process whether the player is doing a Jumping Jack
                if rootangleDIffDegrees < 180 && JJangleDIffDegrees <= 90 && self.wasInTopJJ && PoseEstimator.shared.isworkout == false && self.wholebodyshown == true{
                    if self.isGoodJJPosture {
                        PoseEstimator.shared.currentaccuracy += 1
                    }
                    PoseEstimator.shared.JumpingJackCounter += 1
                    self.wasInTopJJ = false
                    PoseEstimator.shared.caloriesBurntJJ = Float(PoseEstimator.shared.JumpingJackCounter) * 0.2
                }
                if angleDiffDegrees < 180 && JJangleDIffDegrees <= 90 && self.wasInTopJJ && PoseEstimator.shared.isworkout == true  && PoseEstimator.shared.isbreak == false && self.wholebodyshown == true{
                    if self.isGoodJJPosture {
                        PoseEstimator.shared.currentaccuracy += 1
                    }
                    PoseEstimator.shared.currentReps -= 1
                    self.wasInTopJJ = false
                    PoseEstimator.shared.totalworkoutcaloriesburnt += 0.2
                }
                else if rootangleDIffDegrees < 180 && JJangleDIffDegrees <= 90 && self.wasInTopJJ == false && PoseEstimator.shared.isworkout == false && self.wholebodyshown == true{
                    PoseEstimator.shared.JJdisplay = "raise arms higher"
                }
                
                if elbowHeight > shoulderheight && JJangleDIffDegrees >= 130 && rootangleDIffDegrees > 175{ // determining if the user's arms are above the shoulders
                    self.wasInTopJJ = true
                }
                
                //posture check for squats
                if rightAnkle != CGPoint(x: 0.0, y: 1.0) && leftAnkle != CGPoint(x: 0.0, y: 1.0) && rightKnee != CGPoint(x: 0.0, y: 1.0) && leftKnee != CGPoint(x: 0.0, y: 1.0) && rightHip != CGPoint(x: 0.0, y: 1.0)
                    && leftHip != CGPoint(x: 0.0, y: 1.0) && root != CGPoint(x: 0.0, y: 1.0) && neck != CGPoint(x: 0.0, y: 1.0) && rightShoulder != CGPoint(x: 0.0, y: 1.0)
                    && leftShoulder != CGPoint(x: 0.0, y: 1.0)
                    && leftElbow != CGPoint(x: 0.0, y: 1.0)
                    && rightElbow != CGPoint(x: 0.0, y: 1.0)
                    && leftWrist != CGPoint(x: 0.0, y: 1.0)
                    && rightWrist != CGPoint(x: 0.0, y: 1.0){
                    self.wholebodyshown = true
                    self.error = "no error"
                }
                if rightAnkle == CGPoint(x: 0.0, y: 1.0) || leftAnkle == CGPoint(x: 0.0, y: 1.0) || rightKnee == CGPoint(x: 0.0, y: 1.0) || leftKnee == CGPoint(x: 0.0, y: 1.0) || rightHip == CGPoint(x: 0.0, y: 1.0)
                            || leftHip == CGPoint(x: 0.0, y: 1.0) || root == CGPoint(x: 0.0, y: 1.0) || neck == CGPoint(x: 0.0, y: 1.0) || rightShoulder == CGPoint(x: 0.0, y: 1.0)
                            || leftShoulder == CGPoint(x: 0.0, y: 1.0)
                            || leftElbow == CGPoint(x: 0.0, y: 1.0)
                            || rightElbow == CGPoint(x: 0.0, y: 1.0)
                            || leftWrist == CGPoint(x: 0.0, y: 1.0)
                            || rightWrist == CGPoint(x: 0.0, y: 1.0){
                    self.wholebodyshown = false
                    self.error = "wholebodyisntinframe"
                }
                
            case "Push Ups":
                //posture check for squats
                if rightAnkle != CGPoint(x: 0.0, y: 1.0) && leftAnkle != CGPoint(x: 0.0, y: 1.0) && rightKnee != CGPoint(x: 0.0, y: 1.0) && leftKnee != CGPoint(x: 0.0, y: 1.0) && rightHip != CGPoint(x: 0.0, y: 1.0)
                    && leftHip != CGPoint(x: 0.0, y: 1.0) && root != CGPoint(x: 0.0, y: 1.0) && neck != CGPoint(x: 0.0, y: 1.0) && rightShoulder != CGPoint(x: 0.0, y: 1.0)
                    && leftShoulder != CGPoint(x: 0.0, y: 1.0)
                    && leftElbow != CGPoint(x: 0.0, y: 1.0)
                    && rightElbow != CGPoint(x: 0.0, y: 1.0)
                    && leftWrist != CGPoint(x: 0.0, y: 1.0)
                    && rightWrist != CGPoint(x: 0.0, y: 1.0){
                    self.wholebodyshown = true
                    self.error = "no error"
                }
                if rightAnkle == CGPoint(x: 0.0, y: 1.0) || leftAnkle == CGPoint(x: 0.0, y: 1.0) || rightKnee == CGPoint(x: 0.0, y: 1.0) || leftKnee == CGPoint(x: 0.0, y: 1.0) || rightHip == CGPoint(x: 0.0, y: 1.0)
                            || leftHip == CGPoint(x: 0.0, y: 1.0) || root == CGPoint(x: 0.0, y: 1.0) || neck == CGPoint(x: 0.0, y: 1.0) || rightShoulder == CGPoint(x: 0.0, y: 1.0)
                            || leftShoulder == CGPoint(x: 0.0, y: 1.0)
                            || leftElbow == CGPoint(x: 0.0, y: 1.0)
                            || rightElbow == CGPoint(x: 0.0, y: 1.0)
                            || leftWrist == CGPoint(x: 0.0, y: 1.0)
                            || rightWrist == CGPoint(x: 0.0, y: 1.0){
                    self.wholebodyshown = false
                    self.error = "wholebodyisntinframe"
                }
                
                //process whether the player is doing a pushup
                if PUAngleDiffDegrees > 167 && self.wasInBottomPU && PoseEstimator.shared.isworkout == false && self.wholebodyshown == true{
                    if self.isGoodPUPosture {
                        PoseEstimator.shared.currentaccuracy += 1
                    }
                    PoseEstimator.shared.PushupCounter += 1
                    PoseEstimator.shared.caloriesBurntPushUps = Float(PoseEstimator.shared.PushupCounter) * 0.6
                    wasInBottomPU = false
                    PoseEstimator.shared.PUdisplay = "down!"
                }
                else if PUAngleDiffDegrees < 167 && self.wasInBottomPU == false && self.wholebodyshown == true && self.begin == true{
                }
                if PUAngleDiffDegrees < 167 && self.wasInBottomPU && PoseEstimator.shared.isworkout == true && PoseEstimator.shared.isbreak == false && self.wholebodyshown == true{
                    if self.isGoodPUPosture {
                        PoseEstimator.shared.currentaccuracy += 1
                    }
                    PoseEstimator.shared.currentReps -= 1
                    self.wasInBottomPU = false
                    PoseEstimator.shared.totalworkoutcaloriesburnt += 0.6
                }
                
                if PUAngleDiffDegrees <= 150 {
                    self.wasInBottomPU = true
                }
                
                //posture check for pushup
                if leftElbow.x < (leftShoulder.x - 0.3) || rightElbow.x > (rightShoulder.x + 0.3) {
                    leftelbowcolor = Color.red
                    rightelbowcolor = Color.red
                }
                else if leftElbow.x > (leftShoulder.x - 0.3) && rightElbow.x < (rightShoulder.x + 0.3) {
                    leftelbowcolor = Color.cyan
                    rightelbowcolor = Color.cyan
                }
                if ankleDistance > 10 {
                    rightanklecolor = Color.red
                    leftanklecolor = Color.red
                }
                else if ankleDistance < 10 {
                    rightanklecolor = Color.cyan
                    leftanklecolor = Color.cyan
                }
                
                
            case "Single-Leg-Deadlifts":
                
                //posture check for squats
                if rightAnkle != CGPoint(x: 0.0, y: 1.0) && leftAnkle != CGPoint(x: 0.0, y: 1.0) && rightKnee != CGPoint(x: 0.0, y: 1.0) && leftKnee != CGPoint(x: 0.0, y: 1.0) && rightHip != CGPoint(x: 0.0, y: 1.0)
                    && leftHip != CGPoint(x: 0.0, y: 1.0) && root != CGPoint(x: 0.0, y: 1.0) && neck != CGPoint(x: 0.0, y: 1.0) && rightShoulder != CGPoint(x: 0.0, y: 1.0)
                    && leftShoulder != CGPoint(x: 0.0, y: 1.0)
                    && leftElbow != CGPoint(x: 0.0, y: 1.0)
                    && rightElbow != CGPoint(x: 0.0, y: 1.0)
                    && leftWrist != CGPoint(x: 0.0, y: 1.0)
                    && rightWrist != CGPoint(x: 0.0, y: 1.0){
                    self.wholebodyshown = true
                    self.error = "no error"
                }
                if rightAnkle == CGPoint(x: 0.0, y: 1.0) || leftAnkle == CGPoint(x: 0.0, y: 1.0) || rightKnee == CGPoint(x: 0.0, y: 1.0) || leftKnee == CGPoint(x: 0.0, y: 1.0) || rightHip == CGPoint(x: 0.0, y: 1.0)
                            || leftHip == CGPoint(x: 0.0, y: 1.0) || root == CGPoint(x: 0.0, y: 1.0) || neck == CGPoint(x: 0.0, y: 1.0) || rightShoulder == CGPoint(x: 0.0, y: 1.0)
                            || leftShoulder == CGPoint(x: 0.0, y: 1.0)
                            || leftElbow == CGPoint(x: 0.0, y: 1.0)
                            || rightElbow == CGPoint(x: 0.0, y: 1.0)
                            || leftWrist == CGPoint(x: 0.0, y: 1.0)
                            || rightWrist == CGPoint(x: 0.0, y: 1.0){
                    self.wholebodyshown = false
                    self.error = "wholebodyisntinframe"
                }
                
                //process whether the player is doing a SLDeadlift
                if SLDAngleDiffDegrees >= 215 && self.wasInDeadLift && PoseEstimator.shared.isworkout == false && self.wholebodyshown == true{
                    if self.isGoodSLDPosture {
                        PoseEstimator.shared.currentaccuracy += 1
                    }
                    PoseEstimator.shared.SLDeadliftsCounter += 1
                    wasInDeadLift = false
                    PoseEstimator.shared.caloriesBurntSLD = Float(PoseEstimator.shared.SLDeadliftsCounter) * 0.2
                }
                if SLDAngleDiffDegrees >= 215 && self.wasInDeadLift == false && PoseEstimator.shared.isworkout == false && self.wholebodyshown == true && self.begin == true{
                    PoseEstimator.shared.SLDdisplay = "raise leg higher"
                }
                if SLDAngleDiffDegrees >= 215 && self.wasInDeadLift && PoseEstimator.shared.isworkout == true && PoseEstimator.shared.isbreak == false  && self.wholebodyshown == true{
                    if self.isGoodSLDPosture {
                        PoseEstimator.shared.currentaccuracy += 1
                    }
                    PoseEstimator.shared.currentReps -= 1
                    wasInDeadLift = false
                    PoseEstimator.shared.totalworkoutcaloriesburnt += 0.2
                }
                if hipHeight <= lefthipHeight{
                    self.wasInDeadLift = true
                }
            
            case "Burpees":
                //process whether the player is doing a burpee
                //posture check for squats
                if rightAnkle != CGPoint(x: 0.0, y: 1.0) && leftAnkle != CGPoint(x: 0.0, y: 1.0) && rightKnee != CGPoint(x: 0.0, y: 1.0) && leftKnee != CGPoint(x: 0.0, y: 1.0) && rightHip != CGPoint(x: 0.0, y: 1.0)
                    && leftHip != CGPoint(x: 0.0, y: 1.0) && root != CGPoint(x: 0.0, y: 1.0) && neck != CGPoint(x: 0.0, y: 1.0) && rightShoulder != CGPoint(x: 0.0, y: 1.0)
                    && leftShoulder != CGPoint(x: 0.0, y: 1.0)
                    && leftElbow != CGPoint(x: 0.0, y: 1.0)
                    && rightElbow != CGPoint(x: 0.0, y: 1.0)
                    && leftWrist != CGPoint(x: 0.0, y: 1.0)
                    && rightWrist != CGPoint(x: 0.0, y: 1.0){
                    self.wholebodyshown = true
                    self.error = "no error"
                }
                if rightAnkle == CGPoint(x: 0.0, y: 1.0) || leftAnkle == CGPoint(x: 0.0, y: 1.0) || rightKnee == CGPoint(x: 0.0, y: 1.0) || leftKnee == CGPoint(x: 0.0, y: 1.0) || rightHip == CGPoint(x: 0.0, y: 1.0)
                            || leftHip == CGPoint(x: 0.0, y: 1.0) || root == CGPoint(x: 0.0, y: 1.0) || neck == CGPoint(x: 0.0, y: 1.0) || rightShoulder == CGPoint(x: 0.0, y: 1.0)
                            || leftShoulder == CGPoint(x: 0.0, y: 1.0)
                            || leftElbow == CGPoint(x: 0.0, y: 1.0)
                            || rightElbow == CGPoint(x: 0.0, y: 1.0)
                            || leftWrist == CGPoint(x: 0.0, y: 1.0)
                            || rightWrist == CGPoint(x: 0.0, y: 1.0){
                    self.wholebodyshown = false
                    self.error = "wholebodyisntinframe"
                }
                
                if self.wasinupright == true && self.wasinalmostdoneBurpee == true && PoseEstimator.shared.chosenExercise == "Burpees" && PoseEstimator.shared.isworkout == false && self.wholebodyshown == true{
                    PoseEstimator.shared.currentaccuracy += 1
                    PoseEstimator.shared.halfburpee += 1
                    self.wasinupright = false
                    self.wasInBottomBurpee = false
                    self.wasInMidBurpee = false
                    self.down = false
                    self.wasinalmostdoneBurpee = false
                }
                if PoseEstimator.shared.halfburpee >= 2{
                    PoseEstimator.shared.BurpeesCounter += 1
                    PoseEstimator.shared.halfburpee = 0
                    PoseEstimator.shared.caloriesBurntBurpees = Float(PoseEstimator.shared.BurpeesCounter) * 0.5
                }
                if self.wasinupright == true && self.wasinalmostdoneBurpee == true && PoseEstimator.shared.currentexercise == "Burpees" && PoseEstimator.shared.isworkout == true && PoseEstimator.shared.isbreak == false && self.wholebodyshown == true{
                    self.wasinupright = false
                    self.wasInBottomBurpee = false
                    self.wasInMidBurpee = false
                    self.down = false
                    self.wasinalmostdoneBurpee = false
                    PoseEstimator.shared.halfburpee += 1
                }
                if PoseEstimator.shared.halfburpee >= 2 && PoseEstimator.shared.currentexercise == "Burpees" && PoseEstimator.shared.isworkout == true && PoseEstimator.shared.isbreak == false && self.wholebodyshown == true {
                    PoseEstimator.shared.currentaccuracy += 1
                    PoseEstimator.shared.currentReps -= 1
                    PoseEstimator.shared.halfburpee = 0
                    PoseEstimator.shared.caloriesBurntBurpees += 0.5
                }
                if BurpeeAngleDiffDegrees >= 240{
                    self.down = true
                }
                if kneeHeight >= elbowHeight{
                    self.wasInMidBurpee = true
                }
                if kneeHeight < elbowHeight && self.wasInMidBurpee == true && self.down == true{
                    self.wasInBottomBurpee = true
                }
                if kneeHeight >= elbowHeight && self.wasInBottomBurpee == true{
                    self.wasinalmostdoneBurpee = true
                }
                if wristheight > ankleheight{
                    self.wasinupright = true
                }else{
                    self.wasinupright = false
                }
                
                
            default:
                print("no exercise selected: \(PoseEstimator.shared.chosenExercise)")
            }
        }
        
        
        
        
        
        if PoseEstimator.shared.currentReps == 0 && PoseEstimator.shared.isworkout == true && PoseEstimator.shared.isbreak == false {
            PoseEstimator.shared.exericseaccuracy.append("\(Int((PoseEstimator.shared.currentaccuracy / Int(PoseEstimator.shared.reps[PoseEstimator.shared.index])!) * 100))")
            var sum = 0
            for string in exericseaccuracy {
                sum += Int(string)!
            }
            if sum != 0 && exericseaccuracy.count != 0 {
                PoseEstimator.shared.overallaccuracy = Int((sum / exericseaccuracy.count) * 100)
            }
            PoseEstimator.shared.isbreak = true
            self.isbreak = true
            PoseEstimator.shared.index += 1
            PoseEstimator.shared.currentexercise = PoseEstimator.shared.Exercises[PoseEstimator.shared.index]
            PoseEstimator.shared.chosenExercise = PoseEstimator.shared.Exercises[PoseEstimator.shared.index]
            print("next exercise: \(PoseEstimator.shared.currentexercise)")
            PoseEstimator.shared.currentReps = Int(PoseEstimator.shared.reps[PoseEstimator.shared.index])!
            print("next reps: \(PoseEstimator.shared.currentReps)")
            if PoseEstimator.shared.currentexercise == "Break" {
                longbreak = true
                timeleft = Int(PoseEstimator.shared.reps[PoseEstimator.shared.index])!
            }
            else {
                timeleft = 15
                shortbreak = true
            }
            
            if PoseEstimator.shared.index == PoseEstimator.shared.Exercises.count - 1 {
                isdone = true
            }
        }
        
    
        

        
        
        
        
        
    }
}
