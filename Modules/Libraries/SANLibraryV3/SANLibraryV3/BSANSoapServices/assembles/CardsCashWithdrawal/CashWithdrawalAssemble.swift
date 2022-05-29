//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class CashWithdrawalAssemble: BSANAssemble {
    
    private static let instance = CashWithdrawalAssemble("ACSADIELSacarDineroEmi", "/SADIEL_SCASH_ENS_SAN/ws/SADIEL_Def_Listener", "SADIEL")
    
    static func getInstance() -> CashWithdrawalAssemble {
        return instance
    }
}
