//
//  ManagerHobbieDTO.swift
//  Models
//
//  Created by César González Palomino on 18/02/2020.
//

import Foundation

public struct ManagerHobbieDTO: Codable {
    public let location: String?
    public let category: String?
    public let userId: String?
    public let managerId: String?
    public let descHobbies: String?

    public init(location: String?, category: String?, userId: String?, managerId: String?, descHobbies: String?) {
        self.location = location
        self.category = category
        self.userId = userId?.trim()
        self.managerId = managerId?.trim()
        self.descHobbies = descHobbies
    }
}
