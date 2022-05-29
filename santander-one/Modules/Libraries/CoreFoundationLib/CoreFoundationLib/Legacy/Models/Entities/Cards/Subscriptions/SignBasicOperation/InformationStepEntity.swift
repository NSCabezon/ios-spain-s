//
//  InformationStepEntity.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 6/5/21.
//

import SANLegacyLibrary

public protocol InformationStepEntityRepresentable {
    var lastStep: String { get }
    var typeSignature: String? { get }

}

public struct InformationStepEntity: InformationStepEntityRepresentable {
    private let dto: InformationStepCurrentSignature
    public init(dto: InformationStepCurrentSignature) {
        self.dto = dto
    }
    
    public var lastStep: String {
        return dto.lastStep
    }
    
    public var typeSignature: String? {
        return dto.typeSignature
    }
}
