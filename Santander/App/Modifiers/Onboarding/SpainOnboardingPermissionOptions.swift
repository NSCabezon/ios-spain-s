//
//  SpainOnboardingPermissionOptions.swift
//  Santander
//
//  Created by José Norberto Hidalgo Romero on 7/2/22.
//

import CoreFoundationLib

class SpainOnboardingPermissionOptions: OnboardingPermissionOptionsProtocol {
    func getOptions() -> [OnboardingPermissionType] {
        [.notifications, .location]
    }
}
