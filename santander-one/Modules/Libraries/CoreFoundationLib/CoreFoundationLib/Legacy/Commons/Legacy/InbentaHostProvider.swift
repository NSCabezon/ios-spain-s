//
// Created by Guillermo on 15/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation

public protocol InbentaHostProvider {
    var inbentaEnvironments: [InbentaEnvironmentDTO] { get }
}
