//
//  CameraView.swift
//  Fitable
//
//  Created by Kiran Lim on 28/8/21.
//

import AVFoundation
import UIKit

final class CameraView: UIView {
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
      }
}
import Foundation
