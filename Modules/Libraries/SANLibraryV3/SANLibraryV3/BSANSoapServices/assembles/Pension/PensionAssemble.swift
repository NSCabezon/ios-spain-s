//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class PensionAssemble: BSANAssemble {

    private static let instance = PensionAssemble("ACBAMOBIPLA", "/SCH_BAMOBI_PLANES_ENS/ws/BAMOBI_WS_Def_Listener")

    static func getInstance() -> PensionAssemble {
		return instance
    }
	
}
