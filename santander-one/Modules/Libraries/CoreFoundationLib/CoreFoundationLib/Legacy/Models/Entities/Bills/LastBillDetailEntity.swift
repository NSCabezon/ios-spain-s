//
//  LastBillDetailEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 15/04/2020.
//

import Foundation
import SANLegacyLibrary

public final class LastBillDetailEntity: DTOInstantiable {
    public var dto: BillDetailDTO
    
    public init(_ dto: BillDetailDTO) {
        self.dto = dto
    }
}
