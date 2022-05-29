//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class CardsAssemble: BSANAssemble {

    private static let ourInstancePB = CardsAssemble("BAMOBITAJ", "/SPB_MOSPCA_WS_ENS/ws/BAMOBI_WS_Def_Listener")
    private static let ourInstance = CardsAssemble("BAMOBITAJ", "/SCH_BAMOBI_WS_ENS/ws/BAMOBI_WS_Def_Listener")

    static func getInstance(isPB: Bool) -> CardsAssemble {
        if (isPB) {
            return ourInstancePB
        } else {
            return ourInstance
        }
    }
}
