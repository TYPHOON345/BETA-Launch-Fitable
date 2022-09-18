//
//  dotview.swift
//  Fitable
//
//  Created by Kiran Lim on 23/1/22.
//

import SwiftUI

@available(iOS 15.0, *)
struct dotview: View {    //declare the stickfigure for pose esimation as a swift view
    @ObservedObject var poseEstimator: PoseEstimator
    
    var size: CGSize
    var body: some View {
        if poseEstimator.bodyParts.isEmpty == false { //add in the sticks only if there are VNPoints stored in "bodyparts"
            ZStack {
                // Right leg
                if poseEstimator.bodyParts[.rightAnkle]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.rightKnee]!.location != CGPoint(x: 0.0, y: 1.0){
                    Circle()
                        .fill(poseEstimator.rightanklecolor)
                        .position(poseEstimator.bodyParts[.rightAnkle]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(poseEstimator.rightkneecolor)
                        .position(poseEstimator.bodyParts[.rightKnee]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                }
                
                if poseEstimator.bodyParts[.rightKnee]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.rightHip]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.root]!.location != CGPoint(x: 0.0, y: 1.0) {
                    Circle()
                        .fill(poseEstimator.rightkneecolor)
                        .position(poseEstimator.bodyParts[.rightKnee]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(poseEstimator.righthipcolor)
                        .position(poseEstimator.bodyParts[.rightHip]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                }
                
                // Left leg
                if poseEstimator.bodyParts[.leftAnkle]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.leftKnee]!.location != CGPoint(x: 0.0, y: 1.0){
                    Circle()
                        .fill(poseEstimator.leftanklecolor)
                        .position(poseEstimator.bodyParts[.leftAnkle]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(poseEstimator.leftkneecolor)
                        .position(poseEstimator.bodyParts[.leftKnee]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                    
                }
                if poseEstimator.bodyParts[.leftKnee]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.leftHip]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.root]!.location != CGPoint(x: 0.0, y: 1.0){
                    Circle()
                        .fill(poseEstimator.leftkneecolor)
                        .position(poseEstimator.bodyParts[.leftKnee]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(poseEstimator.lefthipcolor)
                        .position(poseEstimator.bodyParts[.leftHip]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                }
                
                
                // Right arm
                if poseEstimator.bodyParts[.rightWrist]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.rightElbow]!.location != CGPoint(x: 0.0, y: 1.0){
                    Circle()
                        .fill(poseEstimator.rightwristcolor)
                        .position(poseEstimator.bodyParts[.rightWrist]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(poseEstimator.rightelbowcolor)
                        .position(poseEstimator.bodyParts[.rightElbow]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                }
                
                if poseEstimator.bodyParts[.rightElbow]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.rightShoulder]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.neck]!.location != CGPoint(x: 0.0, y: 1.0){
                    Circle()
                        .fill(poseEstimator.rightelbowcolor)
                        .position(poseEstimator.bodyParts[.rightElbow]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(poseEstimator.rightshouldercolor)
                        .position(poseEstimator.bodyParts[.rightShoulder]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                }
                
                // Left arm
                if poseEstimator.bodyParts[.leftWrist]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.leftElbow]!.location != CGPoint(x: 0.0, y: 1.0){
                    Circle()
                        .fill(poseEstimator.leftwristcolor)
                        .position(poseEstimator.bodyParts[.leftWrist]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(poseEstimator.leftelbowcolor)
                        .position(poseEstimator.bodyParts[.leftElbow]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                }
                
                if poseEstimator.bodyParts[.leftElbow]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.leftShoulder]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.neck]!.location != CGPoint(x: 0.0, y: 1.0){
                    Circle()
                        .fill(poseEstimator.leftelbowcolor)
                        .position(poseEstimator.bodyParts[.leftElbow]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(poseEstimator.leftshouldercolor)
                        .position(poseEstimator.bodyParts[.leftShoulder]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                }
                // Root to nose
                if poseEstimator.bodyParts[.root]!.location != CGPoint(x: 0.0, y: 1.0) && poseEstimator.bodyParts[.neck]!.location != CGPoint(x: 0.0, y: 1.0){
                    Circle()
                        .fill(poseEstimator.rootcolor)
                        .position(poseEstimator.bodyParts[.root]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                    Circle()
                        .fill(poseEstimator.neckcolor)
                        .position(poseEstimator.bodyParts[.neck]!.location.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                        .frame(width: 15, height: 15)
                }
                
                
                    
                }
            }
        }
}



