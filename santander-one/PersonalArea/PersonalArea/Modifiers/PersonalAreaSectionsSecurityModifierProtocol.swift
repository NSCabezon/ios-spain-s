//
//  PersonalAreaSectionsSecurityModifierProtocol.swift
//  PersonalArea
//
//  Created by Rubén Muñoz López on 9/9/21.
//

import UIKit

public protocol PersonalAreaSectionsSecurityModifierProtocol {
    var isDisabledUser: Bool { get }
    var isEnabledPassword: Bool { get }
    var isEnabledSignature: Bool { get }
    var isEnabledDataPrivacy: Bool { get }
    var isEnabledLastAccess: Bool { get }
    var isESignatureFunctionalityEnabled: Bool { get }
    var isBiometryFunctionalityEnabled: Bool { get }
    var isEnabledQuickerBalance: Bool { get }
    func getCustomSecurityDeviceView() -> UIView?
}

public extension PersonalAreaSectionsSecurityModifierProtocol {
    var isBiometryFunctionalityEnabled: Bool {
        return true
    }
    var isEnabledQuickerBalance: Bool {
        return false
    }
    
    func getCustomSecurityDeviceView() -> UIView? {
        return nil
    }
}
