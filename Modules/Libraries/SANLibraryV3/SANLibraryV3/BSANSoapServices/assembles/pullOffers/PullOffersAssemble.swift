//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class PullOffersAssemble: BSANAssemble {

    private static let ourInstance = PullOffersAssemble("ACOFECOM", "/SCH_OFECOM_OFERTASCOMERCIALES_ENS/ws/BAMOBI_WS_Def_Listener")

    static func getInstance() -> PullOffersAssemble {
        return ourInstance
    }
}

