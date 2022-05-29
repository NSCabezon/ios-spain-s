//
//  Environment.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 12/5/21.
//

import SANSpainLibrary

struct Environment: EnvironmentRepresentable {
    let soapBaseUrl: String
    let restBaseUrl: String
    let santanderKeyUrl: String
}

extension Environment {
    static var pro: Environment {
        return Environment(soapBaseUrl: "https://www.bsan.mobi", restBaseUrl: "https://sanesp.mobi", santanderKeyUrl: "https://sankey.mobi")
    }
}

