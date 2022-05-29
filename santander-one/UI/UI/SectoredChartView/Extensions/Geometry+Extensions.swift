//
//  Geometry+Extensions.swift
//
//  Created by Boris Chirino Fernandez on 26/08/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit

extension CGRect {
  init(centeredOn center: CGPoint, size: CGSize) {
    self.init( origin: CGPoint(
                x: center.x - size.width/2,
                y: center.y - size.height/2), size: size
    )
  }

  var center: CGPoint {
    return CGPoint(
        x: origin.x + size.width/2,
        y: origin.y + size.height/2
    )
  }
}

extension CGPoint {
    /// displace a point by value, taking into account the angle of the arc
    /// - Parameters:
    ///   - value: this value represent how much the point must be moved away
    ///   - angle: used to correct the trayectory of the displaced point
  func projected(by value: CGFloat, angle: CGFloat) -> CGPoint {
    return CGPoint(
      x: x + value * cos(angle),
      y: y + value * sin(angle)
    )
  }
}

extension Double {
    public var toCGFloat: CGFloat {
        CGFloat(self)
    }
}
