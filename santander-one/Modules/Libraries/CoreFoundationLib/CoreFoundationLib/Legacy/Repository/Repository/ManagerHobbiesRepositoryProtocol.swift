//
//  ManagerHobbiesRepositoryProtocol.swift
//  Commons
//
//  Created by César González Palomino on 18/02/2020.
//

import Foundation


public protocol ManagerHobbiesRepositoryProtocol {
    func getManagerHobbies() -> ManagerHobbieListDTO?
    func loadManagerHobbies(baseUrl: String, publicLanguage: PublicLanguage)
}
