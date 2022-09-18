//
//  CorrectionsView.swift
//  Fitable
//
//  Created by Kiran Lim on 12/9/22.
//

import Foundation
import SwiftUI
import UIKit
import AVKit

@available(iOS 15.0, *)
struct correctionsview: View{
    
    @ObservedObject var poseEstimator: PoseEstimator
    
    var size: CGSize
    
    var body: some View{
        ZStack{
            switch poseEstimator.error {
            case "stancetoowideornarrow":
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [7], dashPhase: 2))
                    .frame(width: 50, height: 20)
                    .foregroundColor(.green)
                    .position(CGPoint(x: poseEstimator.bodyParts[.leftShoulder]!.location.x, y: poseEstimator.bodyParts[.leftAnkle]!.location.y).applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [7], dashPhase: 2))
                    .frame(width: 50, height: 20)
                    .foregroundColor(.green)
                    .position(CGPoint(x: poseEstimator.bodyParts[.rightShoulder]!.location.x, y: poseEstimator.bodyParts[.rightAnkle]!.location.y).applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
            case "kneesdonttrackoverfeet":
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 7, lineCap: .round, dash: [7], dashPhase: 2))
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green)
                    .position(CGPoint(x: poseEstimator.bodyParts[.rightAnkle]!.location.x - 0.1, y: poseEstimator.bodyParts[.rightKnee]!.location.y).applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 7, lineCap: .round, dash: [7], dashPhase: 2))
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green)
                    .position(CGPoint(x: poseEstimator.bodyParts[.leftAnkle]!.location.x + 0.1, y: poseEstimator.bodyParts[.leftKnee]!.location.y).applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)))
            case "wholebodyisntinframe":
                Text("your whole body isn't in the camera frame")
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                    .background(Color.red)
                    .cornerRadius(10)
                    .animation(Animation.easeIn(duration: 2), value: 3)
            case "you get up on your toes":
                Stick(points: [CGPoint(x: 0.0, y: poseEstimator.rightheelheight), CGPoint(x: 1.0, y: poseEstimator.leftheelheight)], size: size)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [10], dashPhase: 2))
                    .fill(Color.green)
            
                
            default:
                EmptyView()
            }
        }
    }
}


