//
//  OTPConfigurationProtocol.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 4/12/21.
//

import Foundation

public protocol OTPConfigurationProtocol {
    var maxlength: Int { get }
    var shouldResendCode: Bool { get }
    var hasTitleAndNotAlignmentCenter: Bool { get }
}

public extension OTPConfigurationProtocol {
    var shouldResendCode: Bool { return true }
}
