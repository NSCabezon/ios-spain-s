//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class AuthenticateCredentialAssemble: BSANAssemble {

    private static let ourInstanceV1 = AuthenticateCredentialAssemble("loginServicesNSegSAN", "/SANMOV_IPAD_NSeg_ENS/ws/SANMOVNS_Def_Listener")
    private static let ourInstanceV2 = AuthenticateCredentialAssemble("loginServicesNSegSAN", "/SANMOV_IPAD_NSeg_ENS/ws/SANMOV_Def_Listener")

    static func getInstance(isV1: Bool) -> AuthenticateCredentialAssemble {
        if (isV1) {
            return ourInstanceV1
        } else {
            return ourInstanceV2
        }
    }
}
