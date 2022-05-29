//
//  Bundle+extension.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/23/19.
//

import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: CardsModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "Cards", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
