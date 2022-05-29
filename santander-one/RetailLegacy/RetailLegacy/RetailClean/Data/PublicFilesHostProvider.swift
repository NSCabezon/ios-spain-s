//
// Created by Guillermo on 15/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import CoreFoundationLib

public protocol PublicFilesHostProvider: PublicFilesHostProviderProtocol {
    var publicFilesEnvironments: [PublicFilesEnvironmentDTO] { get }
}
