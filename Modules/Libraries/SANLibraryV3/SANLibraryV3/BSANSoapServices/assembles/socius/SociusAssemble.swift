//
// Created by Guillermo on 6/2/18.
// Copyright (c) 2018 com.ciber. All rights reserved.
//

import Foundation

public class SociusAssemble: BSANAssemble {

    private static let ourInstance = SociusAssemble("socius", "/adn-ws-socius-s/ADNCalSOCPortS")

    static func getInstance() -> SociusAssemble {
        return ourInstance
    }
}

