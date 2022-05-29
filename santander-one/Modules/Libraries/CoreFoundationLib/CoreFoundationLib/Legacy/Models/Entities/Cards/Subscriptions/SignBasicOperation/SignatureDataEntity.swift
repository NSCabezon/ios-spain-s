//
//  SignatureDataEntity.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 6/5/21.
//

import Foundation

import SANLegacyLibrary

public protocol SignatureDataEntityRepresentable {
    var length: String { get }
    var positions: String { get }
    var values: [String]? { get set }
}

public struct SignatureDataEntity: SignatureDataEntityRepresentable {
    
    private var dto: SignatureData
    public init(dto: SignatureData) {
        self.dto = dto
    }
    
    public var length: String {
        return dto.length
    }
    
    public var positions: String {
        return dto.positions
    }
    
    public var values: [String]? {
        get {
            return dto.values
        }
        set {
            dto.values = newValue
        }
    }
    
    public func getValues() -> String? {
        guard let values = values else { return nil }
        return values.joined(separator: " ")
    }
}
