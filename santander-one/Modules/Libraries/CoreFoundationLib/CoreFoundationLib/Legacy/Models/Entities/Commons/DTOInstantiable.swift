//
//  EntityInstantiable.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 02/10/2019.
//  Copyright © 2019 Jose Carlos Estela Anguita. All rights reserved.
//

import SANLegacyLibrary

public protocol DTOInstantiable {
    associatedtype DTO
    init(_ dto: DTO)
    var dto: DTO { get }
}
