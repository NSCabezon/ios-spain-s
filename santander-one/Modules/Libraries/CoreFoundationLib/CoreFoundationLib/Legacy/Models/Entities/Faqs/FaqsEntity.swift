//
//  FaqsEntity.swift
//  Models
//
//  Created by Carlos Gutiérrez Casado on 02/03/2020.
//

import Foundation
import CoreDomain

public final class FaqsEntity: DTOInstantiable {
    public let dto: FaqDTO
    
    public init(_ dto: FaqDTO) {
        self.dto = dto
    }
    
    public var id: Int? {
        return dto.identifier
    }
    
    public var keywords: [String]? {
        return dto.keywords
    }
    
    public var answer: String {
        return dto.answer
    }
    
    public var question: String {
        return dto.question
    }
    
    public var icon: String? {
        return dto.icon
    }
}

extension FaqsEntity: FaqRepresentable {
    public var identifier: Int? {
        return self.id
    }
}
