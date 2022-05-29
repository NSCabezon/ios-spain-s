//
// Created by Guillermo on 22/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
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
                        BSANEnvironments.environmentDev]
            }

            var environmentDefault: BSANEnvironmentDTO {
                return BSANEnvironments.environmentPro
            }
        }
        return BSANHostProviderImpl()
    }

    public func providesPublicFilesHostProvider() -> PublicFilesHostProviderProtocol {
        struct PublicFilesHostProviderImpl: PublicFilesHostProviderProtocol {
            private(set) var publicFilesEnvironments: [PublicFilesEnvironmentDTO] = [
                PublicFilesEnvironments.xmlEnvironmentFF,
                PublicFilesEnvironments.xmlEnvironmentRC,
                PublicFilesEnvironments.xmlEnvironmentCiberQA,
                PublicFilesEnvironments.xmlEnvironmentCiberIsban,
                PublicFilesEnvironments.xmlEnvironmentCiberNegocio,
                PublicFilesEnvironments.xmlEnvironmentPruebas,
                PublicFilesEnvironments.xmlEnvironmentPongodes,
                PublicFilesEnvironments.xmlEnvironmentLocal,
                PublicFilesEnvironments.xmlEnvironmentLocal1,
                PublicFilesEnvironments.xmlEnvironmentLocal2]
        }
        return PublicFilesHostProviderImpl()
    }
}
