//
//  StickFigure.swift
//  Fitable
//
//  Created by Kiran Lim on 28/8/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct StickFigureView: View {    //declare the stickfigure for pose esimation as a swift view
    @ObservedObject var poseEstimator: PoseEstimator
    
    var size: CGSize
    var body: some View {
        if poseEstimator.bodyParts.isEmpty == false { //add in the sticks only if there are VNPoints stored in "bodyparts"
            ZStack {
                
                // Right leg
                if poseEstimator.bodyParts[.rightAnkle]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.rightKnee]!.location != CGPoint(x: 0.0, y: 1.0){
                    Stick(points: [poseEstimator.bodyParts[.rightAnkle]!.location,
                                   poseEstimator.bodyParts[.rightKnee]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.blue)
                }
                
                if poseEstimator.bodyParts[.rightKnee]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.rightHip]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.root]!.location != CGPoint(x: 0.0, y: 1.0) {
                    Stick(points: [poseEstimator.bodyParts[.rightKnee]!.location,
                                   poseEstimator.bodyParts[.rightHip]!.location,
                                   poseEstimator.bodyParts[.root]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.blue)
                }
                
                // Left leg
                if poseEstimator.bodyParts[.leftAnkle]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.leftKnee]!.location != CGPoint(x: 0.0, y: 1.0){
                    Stick(points: [poseEstimator.bodyParts[.leftAnkle]!.location,
                                   poseEstimator.bodyParts[.leftKnee]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.blue)
                }
                if poseEstimator.bodyParts[.leftKnee]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.leftHip]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.root]!.location != CGPoint(x: 0.0, y: 1.0){
                    
                    Stick(points: [poseEstimator.bodyParts[.leftKnee]!.location,
                                   poseEstimator.bodyParts[.leftHip]!.location,
                                   poseEstimator.bodyParts[.root]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.blue)
                }
                
                
                // Right arm
                if poseEstimator.bodyParts[.rightWrist]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.rightElbow]!.location != CGPoint(x: 0.0, y: 1.0){
                    Stick(points: [poseEstimator.bodyParts[.rightWrist]!.location,
                                   poseEstimator.bodyParts[.rightElbow]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.blue)
                }
                
                if poseEstimator.bodyParts[.rightWrist]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.rightElbow]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.neck]!.location != CGPoint(x: 0.0, y: 1.0){
                    Stick(points: [poseEstimator.bodyParts[.rightElbow]!.location,
                                   poseEstimator.bodyParts[.rightShoulder]!.location,
                                   poseEstimator.bodyParts[.neck]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.blue)
                }
                
                // Left arm
                if poseEstimator.bodyParts[.leftWrist]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.leftElbow]!.location != CGPoint(x: 0.0, y: 1.0){
                    Stick(points: [poseEstimator.bodyParts[.leftWrist]!.location,
                                   poseEstimator.bodyParts[.leftElbow]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.blue)
                }
                
                if poseEstimator.bodyParts[.leftElbow]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.leftShoulder]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.neck]!.location != CGPoint(x: 0.0, y: 1.0){
                    Stick(points: [poseEstimator.bodyParts[.leftElbow]!.location,
                                   poseEstimator.bodyParts[.leftShoulder]!.location,
                                   poseEstimator.bodyParts[.neck]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.blue)
                }
                // Root to nose
                if poseEstimator.bodyParts[.root]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.neck]!.location != CGPoint(x: 0.0, y: 1.0){
                    Stick(points: [poseEstimator.bodyParts[.root]!.location,
                                   poseEstimator.bodyParts[.neck]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.blue)
                }
                
                    
                }
            }
        }
}


