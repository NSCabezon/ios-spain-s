//
//  HostModuleDEV.swift
//  RetailClean
//
//  Created by Toni Moreno on 6/12/17.
//  Copyright © 2017 Ciber. All rights reserved.
//

import SANLegacyLibrary
import CoreFoundationLib

public struct HostModule: HostsModuleProtocol {

    public func providesBSANHostProvider() -> BSANHostProviderProtocol {
        struct BSANHostProviderImpl: BSANHostProviderProtocol {
            func getEnvironments() -> [BSANEnvironmentDTO] {
                return [BSANEnvironments.environmentPro,
                        BSANEnvironments.environmentPre,
                        BSANEnvironments.enviromentPreWas9,
                        BSANEnvironments.environmentOcu,
                        BSANEnvironments.environmentDev,
                        BSANEnvironments.environmentCiber]
            }

            var environmentDefault: BSANEnvironmentDTO {
                return BSANEnvironments.environmentPro
            }
        }
        return BSANHostProviderImpl()
    }

    public func providesPublicFilesHostProvider() -> PublicFilesHostProviderProtocol {
        struct PublicFilesHostProviderImpl: PublicFilesHostProviderProtocol {
            private(set) var publicFilesEnvironments: [PublicFilesEnvironmentDTO] = [PublicFilesEnvironments.xmlEnvironmentFF,
                                                                                     PublicFilesEnvironments.xmlEnvironmentCiberQA,
                                                                                     PublicFilesEnvironments.xmlEnvironmentRC,
                                                                                     PublicFilesEnvironments.xmlEnvironmentCiberDev,
                                                                                     PublicFilesEnvironments.xmlEnvironmentCiberIsban,
                                                                                     PublicFilesEnvironments.xmlEnvironmentCiberNegocio,
                                                                                     PublicFilesEnvironments.xmlEnvironmentCiberElab,
                                                                                     PublicFilesEnvironments.xmlEnvironmentPruebas,
                                                                                     PublicFilesEnvironments.xmlEnvironmentPongodes,
                                                                                     PublicFilesEnvironments.xmlEnvironmentLocal,
                                                                                     PublicFilesEnvironments.xmlEnvironmentLocal1,
                                                                                     PublicFilesEnvironments.xmlEnvironmentLocal2]
        }
        return PublicFilesHostProviderImpl()
    }
}
