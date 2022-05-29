//
//  OnboardingPermissionOptionsProtocol.swift
//  RetailLegacy
//
//  Created by Victor Carrilero García on 10/02/2021.
//

import Foundation
import CoreFoundationLib

public protocol OnboardingPermissionOptionsProtocol {
    func getOptions() -> [FirstBoardingPermissionType]
}
