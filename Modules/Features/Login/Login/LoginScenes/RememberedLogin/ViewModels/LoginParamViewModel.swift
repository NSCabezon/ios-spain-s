//
//  LoginParam.swift
//  Login
//
//  Created by Juan Carlos López Robles on 12/4/20.
//

import Foundation
import CoreFoundationLib

struct LoginParamViewModel {
    let isBiometric: Bool
    let biometricToken: String?
    let footprint: String?
    let isPb: Bool?
    let password: String
    
    func getAuthLogin(user: PersistedUserEntity?) -> AuthLogin? {
        guard self.isBiometric else {
            return .magic(password)
        }
        guard let token = self.biometricToken,
              let footprint = self.footprint,
              let channelFrame = user?.channelFrame,
              let isPb = self.isPb else {
              return nil
        }
        return .biometric(
            biometricToken: token,
            footprint: footprint,
            channelFrame: channelFrame,
            isPb: isPb
        )
    }
}
