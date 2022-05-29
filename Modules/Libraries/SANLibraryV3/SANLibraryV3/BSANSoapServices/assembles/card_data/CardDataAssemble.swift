//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class CardDataAssemble: BSANAssemble {

    private static let ourInstance = CardDataAssemble("ACTARSANConsultaImagen", "/TARSAN_CONSULTAIMAGEN_ENS_SAN/ws/TARSAN_Def_Listener")

    static func getInstance() -> CardDataAssemble {
        return ourInstance
    }
}