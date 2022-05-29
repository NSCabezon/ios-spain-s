//
//  Bundle+Extension.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 02/07/2019.
//

import Foundation

extension Bundle {
    static let module: Bundle? = {
        let podBundle = Bundle(for: TimeLine.self)
        let bundleURL = podBundle.url(forResource: "FinantialTimeline", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
}
