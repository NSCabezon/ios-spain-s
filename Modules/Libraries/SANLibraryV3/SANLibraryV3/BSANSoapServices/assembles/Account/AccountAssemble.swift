//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class AccountAssemble: BSANAssemble {

    private static let instance = AccountAssemble("BAMOBICTA", "/SCH_BAMOBI_WS_ENS/ws/BAMOBI_WS_Def_Listener")
    private static let instancePb = AccountAssemble("BAMOBICTA", "/SCH_BAMOBI_WS_ENS/ws/BAMOBI_WS_Def_Listener")

    static func getInstance(isPb: Bool) -> AccountAssemble {
        return (isPb)
            ? instancePb
            : instance
    }
}
