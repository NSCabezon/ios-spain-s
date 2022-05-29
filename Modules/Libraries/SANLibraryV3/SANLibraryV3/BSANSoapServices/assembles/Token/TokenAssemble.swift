//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class TokenAssemble: BSANAssemble {

    private static let instance = TokenAssemble("loginServicesSegSAN", "/SANMOV_IPAD_Seg_ENS/ws/SANMOV_Def_Listener")

    static func getInstance() -> TokenAssemble {
		return instance
    }
	
}
