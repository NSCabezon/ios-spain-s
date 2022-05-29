//
//  InbentaEnvironments.swift
//  RetailClean
//
//  Created by Toni Moreno on 11/12/17.
//  Copyright © 2017 Ciber. All rights reserved.
//

import CoreFoundationLib
import Foundation

struct InbentaEnvironments {
    // Entornos Inbenta
    static let inbentaEndpointProd = "https://santander-avatar.inbenta.com/"
    static let inbentaEndpointStaging = "https://santander.inbenta.com/avatar_staging/"
    
    static let inbentaEnvironmentProd = InbentaEnvironmentDTO("PROD", inbentaEndpointProd, "")
    static let inbentaEnvironmentStaging = InbentaEnvironmentDTO("STAGING", inbentaEndpointStaging, "")
}
