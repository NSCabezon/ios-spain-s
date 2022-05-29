//
//  Bundle+extension.swift
//  PROJECT
//
//  Created by Juan Carlos López Robles on 11/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: AccountsModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "Account", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
