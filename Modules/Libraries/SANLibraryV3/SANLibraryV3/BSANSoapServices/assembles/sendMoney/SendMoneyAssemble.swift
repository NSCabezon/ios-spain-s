//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class SendMoneyAssemble: BSANAssemble {

    private static let ourInstance = SendMoneyAssemble("ACSWENDIEnvioDinero", "/SWENDI_ENVIODINERO_ENS_SAN/ws/BAMOBI_WS_Def_Listener", "SWENDI")

    static func getInstance() -> SendMoneyAssemble {
        return ourInstance
    }
}

