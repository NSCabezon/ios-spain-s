//
//  ValidatedDeviceStateEntity.swift
//  Models
//
//  Created by Juan Carlos López Robles on 2/3/20.
//

import Foundation
import SANLegacyLibrary

public enum ValidatedDeviceStateEntity: Int {
    case rightRegisteredDevice = 0
    case anotherRegisteredDevice
    case notRegisteredDevice
}
