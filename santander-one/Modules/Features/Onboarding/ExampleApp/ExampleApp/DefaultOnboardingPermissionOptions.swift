//
//  DefaultOnboardingPermissionOptions.swift
//  ExampleApp
//
//  Created by Jose Camallonga on 3/2/22.
//

import Foundation
import CoreFoundationLib

struct DefaultOnboardingPermissionOptions: OnboardingPermissionOptionsProtocol {
    func getOptions() -> [OnboardingPermissionType] {
        return [.location, .notifications]
    }
}
