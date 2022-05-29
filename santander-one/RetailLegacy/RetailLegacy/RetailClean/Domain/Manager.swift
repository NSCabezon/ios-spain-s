//
// Created by SYS_CIBER_ADMIN on 13/4/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation
import SANLegacyLibrary
import Operative
import CoreFoundationLib


extension Manager: OpinatorParametrizable {
    var parameters: [PresentationOpinatorParameter: String]? {
        guard let codGest = dto.codGest else {
            return nil
        }
        return [.codGest: codGest]
    }
}
