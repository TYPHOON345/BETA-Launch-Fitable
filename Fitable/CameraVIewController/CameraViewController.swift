

//
//  CameraViewController.swift
//  Fitable
//
//  Created by Kiran Lim on 28/8/21.
//
import Foundation
import UIKit
import AVFoundation
import Vision
import SwiftUI

final class CameraViewController: UIViewController {
    private var cameraSession: AVCaptureSession?
    var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?    //setup AVFoundation camera session
    private let cameraQueue = DispatchQueue(
        label: "CameraOutput",
        qos: .userInteractive
    )
    override func loadView() {
        view = CameraView()       //set view as class CameraView
    }
    private var cameraView: CameraView { view as! CameraView }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraSession == nil {
                try prepareAVSession()
                cameraView.previewLayer.session = cameraSession      //set preview layer as cameraSession
                cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            cameraSession?.startRunning() //start CameraSession
        } catch {
            print(error.localizedDescription)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        cameraSession?.stopRunning()
        super.viewWillDisappear(animated) //stop cameraSession when user exits out of view
    }
    func prepareAVSession() throws {
        let session = AVCaptureSession()
        session.beginConfiguration()         //configure AVFoundation camera session for our use
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard let videoDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera,        //set camera as phone selfie cam
                for: .video,
                position: .front)
        else { return }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice)
        else { return }
        
        guard session.canAddInput(deviceInput)    // add the selfie cam as the input device
        else { return }
        
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput() //set the output of the Cam session as the AVFoundation
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.setSampleBufferDelegate(delegate, queue: cameraQueue)
        } else { return }
        
        session.commitConfiguration()
        cameraSession = session
    }
}




