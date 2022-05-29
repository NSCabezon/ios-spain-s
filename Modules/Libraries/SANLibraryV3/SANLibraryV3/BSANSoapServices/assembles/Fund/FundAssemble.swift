//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class FundAssemble: BSANAssemble {

    private static let instance = FundAssemble("ACBAMOBIFON", "/SCH_BAMOBI_FONDOS_ENS/ws/BAMOBI_WS_Def_Listener")

    static func getInstance() -> FundAssemble {
		return instance
    }
	
}
