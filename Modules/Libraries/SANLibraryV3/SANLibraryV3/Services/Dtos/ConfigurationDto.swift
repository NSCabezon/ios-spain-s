//
//  ConfigurationDto.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 28/5/21.
//

import SANSpainLibrary

struct ConfigurationDto: ConfigurationRepresentable {
    var mulmovUrls: [String] = []
    var appInfo: AppInfoRepresentable?
    var specialLanguageServiceNames: [String] = []
}
