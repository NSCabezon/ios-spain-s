//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class CardsPrepaidAssemble: BSANAssemble {

    private static let ourInstance = CardsPrepaidAssemble("ACTARSANRecargaECash", "/TARSAN_WALLET_ENS_SAN/ws/BAMOBI_WS_Def_Listener")

    static func getInstance() -> CardsPrepaidAssemble {
        return ourInstance
    }
}