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
}

extension Environment {
    static var pre: Environment {
        return Environment(
            soapBaseUrl: "https://movretail.santander.pre.corp",
            restBaseUrl: "https://sanesp-pre.pru.bsch"
        )
    }
}
