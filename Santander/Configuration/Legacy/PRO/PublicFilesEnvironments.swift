//
// Created by Guillermo on 22/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import CoreFoundationLib

struct PublicFilesEnvironments {
    static let xmlEndpointProd: String = "https://microsite.bancosantander.es/filesFF/"
    static let xmlEnvironmentPro = PublicFilesEnvironmentDTO("SAN_FF", xmlEndpointProd, false)
}
