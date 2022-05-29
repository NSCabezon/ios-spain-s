//
//  ConfigurationRepresentable.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 28/5/21.
//

import Foundation

public protocol ConfigurationRepresentable {
    var mulmovUrls: [String] { get set }
    var appInfo: AppInfoRepresentable? { get set }
    var specialLanguageServiceNames: [String] { get set }
}
