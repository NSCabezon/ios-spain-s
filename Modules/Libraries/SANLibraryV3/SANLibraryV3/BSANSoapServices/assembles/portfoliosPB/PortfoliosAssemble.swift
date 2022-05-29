//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class PortfoliosAssemble: BSANAssemble {

    private static let ourInstance = PortfoliosAssemble("", "/SPB_MOSPCA_CARTERAS_ENS/ws/BAMOBI_WS_Def_Listener")

    static func getInstance() -> PortfoliosAssemble {
        return ourInstance
    }
}

