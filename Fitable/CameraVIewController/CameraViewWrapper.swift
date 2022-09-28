//
//  CameraViewWrapper.swift
//  Fitable
//
//  Created by Kiran Lim on 28/8/21.
//
import Foundation
import SwiftUI
import AVFoundation
import Vision


@available(iOS 15.0, *)
struct CameraViewWrapper: UIViewControllerRepresentable {
    var poseEstimator: PoseEstimator
    func makeUIViewController(context: Context) -> some UIViewController {
        let cvc = CameraViewController()
        cvc.delegate = poseEstimator
        return cvc
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
