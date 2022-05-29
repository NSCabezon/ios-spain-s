//
// Created by Guillermo on 16/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation

public protocol DAOInbentaEnvironment {

    func remove() -> Bool

    func set(inbentaEnvironmentDTO: InbentaEnvironmentDTO) -> Bool

    func get() -> InbentaEnvironmentDTO?
}
