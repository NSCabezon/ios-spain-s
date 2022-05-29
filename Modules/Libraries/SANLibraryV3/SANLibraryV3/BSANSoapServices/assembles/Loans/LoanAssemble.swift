//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class LoanAssemble: BSANAssemble {

    private static let instance = LoanAssemble("ACBAMOBIPRE", "/SCH_BAMOBI_PRESTAMOS_ENS/ws/BAMOBI_WS_Def_Listener")

    static func getInstance() -> LoanAssemble {
		return instance
    }
	
}
