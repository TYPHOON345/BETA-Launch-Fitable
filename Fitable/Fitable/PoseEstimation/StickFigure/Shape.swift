//
//  Shape.swift
//  Fitable
//
//  Created by Kiran Lim on 28/8/21.
//

import Foundation
import SwiftUI

struct Stick: Shape { //structure for stick in stickfigure
    var points: [CGPoint]
    var size: CGSize
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: points[0])
        for point in points {
            path.addLine(to: point)
                
            
        }
        return path.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))
            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height))
    }
}
