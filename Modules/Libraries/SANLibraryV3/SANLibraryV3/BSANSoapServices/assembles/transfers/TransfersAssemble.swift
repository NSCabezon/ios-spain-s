//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class TransfersAssemble: BSANAssemble {

    private static let ourInstance = TransfersAssemble("ACBAMOBISEP", "/SCH_BAMOBI_TRANSFCOBROSSEPA_ENS/ws/BAMOBI_WS_Def_Listener");
    private static let ourInstancePB = TransfersAssemble("ACBAMOBISEP", "/SPB_MOSPCA_TRANSFCOBROSSEPA_ENS/ws/BAMOBI_WS_Def_Listener");

    static func getInstance(isPB: Bool) -> TransfersAssemble {
        if (isPB) {
            return ourInstancePB
        } else {
            return ourInstance
        }
    }
}
