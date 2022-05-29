//
//  GetHomeUserPreferencesUseCase.swift
//  PersonalArea
//
//  Created by alvola on 4/4/22.
//

import Foundation
import OpenCombine
import CoreFoundationLib
import CoreDomain

public protocol GetHomeUserPreferencesUseCase {
    func fetchUserPreferences() -> AnyPublisher<PersonalAreaDigitalProfileAndSecurityEnable, Never>
}

public struct PersonalAreaDigitalProfileAndSecurityEnable {
    let isEnabledDigitalProfileView: Bool
    let isPersonalAreaSecuritySettingEnabled: Bool
    
    public init(isEnabledDigitalProfileView: Bool,
                isPersonalAreaSecuritySettingEnabled: Bool) {
        self.isEnabledDigitalProfileView = isEnabledDigitalProfileView
        self.isPersonalAreaSecuritySettingEnabled = isPersonalAreaSecuritySettingEnabled
    }
}
