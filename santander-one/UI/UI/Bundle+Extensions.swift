//
//  Bundle+Extensions.swift
//  UI
//
//  Created by Jose Carlos Estela Anguita on 11/10/2019.
//

import Foundation

extension Bundle {
    static let module: Bundle? = {
        let podBundle = Bundle(for: UIStyle.self)
        let bundleURL = podBundle.url(forResource: "UI", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
    
    public static var uiModule: Bundle? {
        let bundle = Bundle(for: UIStyle.self)
        let bundleURL = bundle.url(forResource: "UI", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }
}
