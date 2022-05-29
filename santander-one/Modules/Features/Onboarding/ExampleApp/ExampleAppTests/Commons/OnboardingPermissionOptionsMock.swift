//
//  OnboardingPermissionOptionsMock.swift
//  ExampleAppTests
//
//  Created by Jose Camallonga on 3/2/22.
//

import Foundation
import CoreFoundationLib

struct OnboardingPermissionOptionsMock: OnboardingPermissionOptionsProtocol {
    func getOptions() -> [OnboardingPermissionType] {
        return [.location, .notifications]
    }
}
