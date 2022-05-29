//
//  ManagerHobbieListDTO.swift
//  Models
//
//  Created by César González Palomino on 18/02/2020.
//

import Foundation

public struct ManagerHobbieListDTO: Codable {
    public let hobbies: [ManagerHobbieDTO]?

    public init(hobbies: [ManagerHobbieDTO]?) {
        self.hobbies = hobbies
    }
    
    enum CodingKeys: String, CodingKey {
        case hobbies = "hoobies"
    }
}
