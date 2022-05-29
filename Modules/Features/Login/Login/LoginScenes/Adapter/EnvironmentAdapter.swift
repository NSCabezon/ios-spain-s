//
//  EnvironmentAdapter.swift
//  Login
//
//  Created by José Carlos Estela Anguita on 31/5/21.
//

import SANSpainLibrary
import CoreFoundationLib

extension EnvironmentEntity: EnvironmentRepresentable {
    public var soapBaseUrl: String {
        return self.dto.urlBase
    }
    
    public var restBaseUrl: String {
        return self.dto.microURL ?? ""
    }

    public var santanderKeyUrl: String {
        return self.dto.santanderKeyUrl ?? ""
    }
}
