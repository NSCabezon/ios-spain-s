//
//  DeviceExtension+Footprint.swift
//  Onboarding
//
//  Created by José Norberto Hidalgo Romero on 12/1/22.
//

import UIKit.UIDevice
import CoreFoundationLib

extension UIDevice {
    func getFootPrint() -> String {
        return IOSDevice().footprint
    }
}
