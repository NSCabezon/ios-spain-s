//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class CMCSignatureAssemble: BSANAssemble {

    private static let ourInstance = CMCSignatureAssemble("ACADFIELGestionCMC", "/ADFIEL_GFC_ENS_SAN/ws/BAMOBI_WS_Def_Listener")

    static func getInstance() -> CMCSignatureAssemble {
        return ourInstance
    }
}