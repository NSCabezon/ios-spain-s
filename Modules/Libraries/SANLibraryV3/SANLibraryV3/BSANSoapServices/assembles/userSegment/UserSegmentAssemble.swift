//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation


public class UserSegmentAssemble: BSANAssemble {

    private static let ourInstance = UserSegmentAssemble("BAMOBIPGL", "/SCH_BAMOBI_WS_ENS/ws/BAMOBI_WS_Def_Listener")

    static func getInstance() -> UserSegmentAssemble {
        return ourInstance
    }
}
