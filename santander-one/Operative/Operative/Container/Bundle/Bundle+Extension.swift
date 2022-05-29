//
//  Bundle+Extension.swift
//  Operative
//
//  Created by Jose Carlos Estela Anguita on 30/12/2019.
//

import Foundation

extension Bundle {
    
    static let module: Bundle? = {
        let podBundle = Bundle(for: OperativeContainer.self)
        let bundleURL = podBundle.url(forResource: "Operative", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
