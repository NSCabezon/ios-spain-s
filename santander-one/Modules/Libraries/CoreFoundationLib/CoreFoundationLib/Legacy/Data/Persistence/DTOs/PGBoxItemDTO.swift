//
//  PGBoxItemDTO.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 14/12/21.
//

import Foundation

public struct PGBoxItemDTO: Codable {
    public var order: Int
    public var isVisible: Bool
    
    public init(order: Int, isVisible: Bool) {
        self.order = order
        self.isVisible = isVisible
    }
}
