//
//  FeeDataEntity.swift
//  Models
//
//  Created by Tania Castellano Brasero on 06/05/2020.
//

import SANLegacyLibrary
import CoreDomain

public struct FeeDataEntity {
    public var representable: FeeDataRepresentable
    public var dto: FeeDataDTO {
        get {
            precondition((representable as? FeeDataDTO) != nil)
            return representable as! FeeDataDTO
        }
        set(newValue) {
            precondition((representable as? FeeDataDTO) != nil)
            representable = newValue
        }
    }
    public init(_ dto: FeeDataDTO) {
        self.representable = dto 
        self.dto = dto
    }
}
