//
//  Bundle+extension.swift
//  Alamofire
//
//  Created by Rubén Márquez Fernández on 27/5/21.
//

import Foundation

extension Bundle {
    static let module: Bundle? = {
        let bundle = Bundle(for: EmptyPurchasesViewController.self)
        let bundleURL = bundle.url(forResource: "ESCommons", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
