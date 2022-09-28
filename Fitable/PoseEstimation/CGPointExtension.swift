//
//  CGPointExtension.swift
//  Fitable
//
//  Created by Kiran Lim on 28/8/21.
//

import Foundation
import UIKit

extension CGPoint { //declare the extension of a CGPoint
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
