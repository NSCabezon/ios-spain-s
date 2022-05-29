//
//  TrickListDTO.swift
//  Models
//
//  Created by Tania Castellano Brasero on 28/04/2020.
//

import Foundation

public struct TrickListDTO: Codable {
    
    public let tricks: [TrickDTO]?
    public let financingTricks: [TrickDTO]?
    
    public init(tricks: [TrickDTO], financingTricks: [TrickDTO]) {
        self.tricks = tricks
        self.financingTricks = financingTricks
    }
}
