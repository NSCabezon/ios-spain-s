//
//  PGModuleDTO.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 14/12/21.
//

import Foundation

public struct PGModuleDTO: Codable {
    public struct Constants {
        public static let yourMoneyModule = "YourMoneyModuleId"
        public static let pfmModule = "PFMModuleId"
    }
    public var isVisible: Bool
}

extension PGModuleDTO {
    init() {
        isVisible = true
    }
}
