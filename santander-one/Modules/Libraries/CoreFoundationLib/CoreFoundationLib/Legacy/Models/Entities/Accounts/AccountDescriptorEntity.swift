//
//  AccountDescriptors.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 07/11/2019.
//

import Foundation

public final class AccountDescriptorEntity {
    
    public let type: String
    public let subType: String
    
    public init(type: String, subType: String) {
        self.type = type
        self.subType = subType
    }
}
