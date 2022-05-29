//
//  InbentaEnvironments.swift
//  RetailClean
//
//  Created by Toni Moreno on 11/12/17.
//  Copyright © 2017 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib

struct InbentaEnvironments {
    static let inbentaEndpointProd = "https://santander-avatar.inbenta.com/"
    static let inbentaEnvironmentProd = InbentaEnvironmentDTO("PROD", inbentaEndpointProd, "")
}
