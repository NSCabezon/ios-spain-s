//
//  PersonalAreaSectionsProtocol.swift
//  PersonalArea
//
//  Created by Luis Escámez Sánchez on 15/03/2021.
//

import Foundation

public protocol PersonalAreaSectionsProtocol {
    func getSecuritySectionCells(_ userPref: UserPrefWrapper?, completion: @escaping ([CellInfo]) -> Void)
}
