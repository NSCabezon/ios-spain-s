//
//  ManagerHobbieEntity.swift
//  Models
//
//  Created by César González Palomino on 18/02/2020.
//

import Foundation

public final class ManagerHobbieEntity: DTOInstantiable {
    
    public let dto: ManagerHobbieDTO
    
    public var location: String {
        return dto.location ?? ""
    }
    
    public var category: String {
        return dto.category ?? ""
    }
    
    public var userId: String {
        return dto.userId ?? ""
    }
    
    public var managerId: String {
        return dto.managerId ?? ""
    }
    
    public var descHobbies: String {
        return dto.descHobbies ?? ""
    }
    
    public init(_ dto: ManagerHobbieDTO) {
        self.dto = dto
    }
}
