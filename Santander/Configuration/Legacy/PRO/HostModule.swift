//
// Created by Guillermo on 22/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import SANLegacyLibrary
import RetailLegacy
import ESCommons
import CoreFoundationLib

public struct HostModule: HostsModuleProtocol {

    public func providesBSANHostProvider() -> BSANHostProviderProtocol {
        struct BSANHostProviderImpl: BSANHostProviderProtocol {
            func getEnvironments() -> [BSANEnvironmentDTO] {
                return [BSANEnvironments.environmentPro]
            }

            var environmentDefault: BSANEnvironmentDTO {
                return BSANEnvironments.environmentPro
            }
        }
        return BSANHostProviderImpl()
    }

    public func providesPublicFilesHostProvider() -> PublicFilesHostProviderProtocol {
        struct PublicFilesHostProviderImpl: PublicFilesHostProvider {
            private(set) var publicFilesEnvironments: [PublicFilesEnvironmentDTO] = [
                PublicFilesEnvironments.xmlEnvironmentPro]
        }
        return PublicFilesHostProviderImpl()
    }
}
