//
//  Bundle+Extension.swift
//  Funds
//
//  Created by Jose Carlos Estela Anguita on 08/10/2019.
//

import Foundation

extension Bundle {
    
    static let module: Bundle? = {
        let podBundle = Bundle(for: DefaultFundsHomeCoordinator.self)
        let bundleURL = podBundle.url(forResource: "Funds", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
