//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class CardsCesAssemble: BSANAssemble {
    
    private static let instance = CardsCesAssemble("ACTARSANAltaCesLa", "/TARSAN_ALTACES_ENS_SAN/ws/BAMOBI_WS_Def_Listener", "TARSAN")
    
    static func getInstance() -> CardsCesAssemble {
        return instance
    }
    
}
