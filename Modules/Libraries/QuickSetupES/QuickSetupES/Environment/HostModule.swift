//
// Created by Guillermo on 22/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation
import SANLegacyLibrary

protocol HostsModuleProtocol {
    static func providesBSANHostProvider() -> BSANHostProviderProtocol
}

struct HostModule: HostsModuleProtocol {
    
    static func providesBSANHostProvider() -> BSANHostProviderProtocol {
        struct BSANHostProviderImpl: BSANHostProviderProtocol {
            func getEnvironments() -> [BSANEnvironmentDTO] {
                return [BSANEnvironments.environmentCiber,
                        BSANEnvironments.environmentDev,
                        BSANEnvironments.environmentPro,
                        BSANEnvironments.environmentPre,
                        BSANEnvironments.environmentOcu]
            }
            
            var environmentDefault: BSANEnvironmentDTO {
                return BSANEnvironments.environmentCiber
            }
        }
        
        return BSANHostProviderImpl()
    }
}
