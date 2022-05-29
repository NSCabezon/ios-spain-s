//
//  SignatureDataInputParamsEntity.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 10/5/21.
//

import Foundation
import SANLegacyLibrary

public protocol SignatureDataInputParamsEntityRepresentable {
    var positions: String { get }
    var positionsValues: String { get }
}

public struct SignatureDataInputParamsEntity: SignatureDataInputParamsEntityRepresentable {
    private let dto: SignatureDataInputParams
    public init(dto: SignatureDataInputParams) {
        self.dto = dto
    }
    
    public var positions: String {
        return dto.positions
    }
    
    public var positionsValues: String {
        return dto.positionsValues
    }
}
