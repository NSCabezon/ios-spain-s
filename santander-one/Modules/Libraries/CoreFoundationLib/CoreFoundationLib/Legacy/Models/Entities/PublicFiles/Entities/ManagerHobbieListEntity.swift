//
//  ManagerHobbieListEntity.swift
//  Models
//
//  Created by César González Palomino on 18/02/2020.
//

import Foundation

public final class ManagerHobbieListEntity: DTOInstantiable {
    public let dto: ManagerHobbieListDTO
    
    public init(_ dto: ManagerHobbieListDTO) {
        self.dto = dto
    }
    
    public var managerHobbiesEntities: [ManagerHobbieEntity] {
        guard let dtoHoobies = dto.hobbies else { return [ManagerHobbieEntity]() }
        
        return dtoHoobies.map { ManagerHobbieEntity($0) }
    }
}
