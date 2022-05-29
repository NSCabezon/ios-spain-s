//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class PersonDataAssemble: BSANAssemble {

    private static let ourInstance = PersonDataAssemble("BAMOBICMN", "/SCH_BAMOBI_WS_ENS/ws/BAMOBI_WS_Def_Listener")

    static func getInstance() -> PersonDataAssemble {
        return ourInstance
    }
}