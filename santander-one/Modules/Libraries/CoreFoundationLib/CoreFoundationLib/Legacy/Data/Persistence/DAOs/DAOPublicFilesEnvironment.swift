//
// Created by Guillermo on 16/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation

public protocol DAOPublicFilesEnvironment {

    func remove() -> Bool

    func set(publicFilesEnvironmentDTO: PublicFilesEnvironmentDTO) -> Bool

    func get() -> PublicFilesEnvironmentDTO?
}
