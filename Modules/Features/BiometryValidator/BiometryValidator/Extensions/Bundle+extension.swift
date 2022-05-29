//
//  Bundle+extension.swift
//  Alamofire
//
//  Created by Rubén Márquez Fernández on 20/5/21.
//

import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: BiometryValidatorModuleCoordinator.self)
        let bundleURL = bundle.url(forResource: "BiometryValidator", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
