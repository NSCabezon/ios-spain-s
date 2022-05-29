//
//  Bundle+Extension.swift
//  Loans
//
//  Created by Jose Carlos Estela Anguita on 08/10/2019.
//

import Foundation

extension Bundle {
    
    static let module: Bundle? = {
        let podBundle = Bundle(for: DefaultLoanHomeCoordinator.self)
        let bundleURL = podBundle.url(forResource: "Loans", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
