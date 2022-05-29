//
// Created by Guillermo on 22/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//
import CoreFoundationLib
import Foundation
import SANLegacyLibrary

struct HostModule: HostsModuleProtocol {

    func providesBSANHostProvider() -> BSANHostProviderProtocol {
        struct BSANHostProviderImpl: BSANHostProviderProtocol {
            func getEnvironments() -> [BSANEnvironmentDTO] {
                return [BSANEnvironments.environmentCiber,
                        BSANEnvironments.environmentDev,
                        BSANEnvironments.environmentPro,
                        BSANEnvironments.environmentPre,
                        BSANEnvironments.enviromentPreWas9,
                        BSANEnvironments.environmentOcu]
            }

            var environmentDefault: BSANEnvironmentDTO {
                return BSANEnvironments.environmentCiber
            }
        }

        return BSANHostProviderImpl()
    }

    func providesPublicFilesHostProvider() -> PublicFilesHostProviderProtocol {
        struct PublicFilesHostProviderImpl: PublicFilesHostProviderProtocol {
            private(set) var publicFilesEnvironments: [PublicFilesEnvironmentDTO] = [
                PublicFilesEnvironments.xmlEnvironmentCiberQA,
                PublicFilesEnvironments.xmlEnvironmentCiberDev,
                PublicFilesEnvironments.xmlEnvironmentRC,
                PublicFilesEnvironments.xmlEnvironmentFF,
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
    
    func providesInbentaHostProvider() -> InbentaHostProvider {
        return InbentaHostProviderImpl()
    }
}

private struct InbentaHostProviderImpl: InbentaHostProvider {
    private(set) var inbentaEnvironments: [InbentaEnvironmentDTO] = []
}

