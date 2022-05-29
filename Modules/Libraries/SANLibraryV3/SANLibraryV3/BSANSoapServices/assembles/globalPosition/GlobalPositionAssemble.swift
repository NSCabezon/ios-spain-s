//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class GlobalPositionAssemble: BSANAssemble {

    private static let ourInstancePB = GlobalPositionAssemble("BAMOBIPGL", "/SPB_MOSPCA_WS_ENS/ws/BAMOBI_WS_Def_Listener")
    private static let ourInstance = GlobalPositionAssemble("BAMOBIPGL", "/SCH_BAMOBI_WS_ENS/ws/BAMOBI_WS_Def_Listener")
    
    private static let  ourInstancePB_V2 = GlobalPositionAssemble("BAMOBIPGL", "/SPB_MOSPCA_PGNEW_ENS/ws/BAMOBI_WS_Def_Listener")
    private static let  ourInstance_V2 = GlobalPositionAssemble("BAMOBIPGL", "/SCH_BAMOBI_PGNEW_ENS/ws/BAMOBI_WS_Def_Listener")

    static func getInstance(isNew: Bool, isPB: Bool) -> GlobalPositionAssemble {
        if (isNew) {
            return getNewAssemble(isPB: isPB)
        } else {
            return getOldAssemble(isPB: isPB)
        }
    }
    
    static func getOldAssemble(isPB: Bool) -> GlobalPositionAssemble {
        if (isPB) {
            return ourInstancePB
        } else {
            return ourInstance
        }
    }
    
    static func getNewAssemble(isPB: Bool) -> GlobalPositionAssemble {
        if (isPB) {
            return ourInstancePB_V2
        } else {
            return ourInstance_V2
        }
    }
}
