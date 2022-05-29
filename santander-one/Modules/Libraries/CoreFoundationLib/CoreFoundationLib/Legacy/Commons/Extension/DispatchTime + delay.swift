//
//  DispatchTime + delay.swift
//  Commons
//
//  Created by César González Palomino on 31/01/2020.
//

import Foundation

extension DispatchTime {
    static var oneSecond: DispatchTime {
        return delay(inSeconds: 1.0)
    }
    
    static func delay(inSeconds seconds: Double) -> DispatchTime {
        return DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    }
}
