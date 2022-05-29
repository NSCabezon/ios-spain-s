//
//  SKSecurityPersonalAreaModifierProtocol.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 13/4/22.
//

import Foundation

public protocol SKSecurityPersonalAreaModifierProtocol {
    func getCustomSecurityDeviceView() -> UIView?
    func isEnabledSantanderKey(completion: @escaping (Bool) -> Void)
}

extension SKSecurityPersonalAreaModifierProtocol {
    
    func getCustomSecurityDeviceView() -> UIView? {
        return nil
    }
    
    func isEnabledSantanderKey(completion: @escaping (Bool) -> Void) {
        completion(false)
    }
}
