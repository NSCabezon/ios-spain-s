//
//  RegisterDeviceRepresentable.swift
//  Onboarding
//
//  Created by José Norberto Hidalgo Romero on 12/1/22.
//

import Foundation

public protocol RegisterDeviceInputRepresentable {
    var footPrint: String { get }
    var deviceName: String { get }
}

public protocol RegisterDeviceOutputRepresentable {
    var deviceMagicPhrase: String { get }
    var touchIDLoginEnabled: Bool { get }
    var deviceId: String { get }
}
