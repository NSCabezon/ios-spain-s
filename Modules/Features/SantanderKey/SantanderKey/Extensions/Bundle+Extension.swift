//
//  Bundle+Extension.swift
//  Account
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import Foundation

extension Bundle {

    static let module: Bundle? = {
        let podBundle = Bundle(for: DefaultSKFirstStepOnboardingCoordinator.self)
        let bundleURL = podBundle.url(forResource: "SantanderKey", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
