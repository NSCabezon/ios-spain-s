//
//  InterventionFilter.swift
//  GlobalPosition
//
//  Created by alvola on 02/01/2020.
//

import SANLegacyLibrary
import CoreDomain

enum PGInterventionFilter: CaseIterable {
    case all
    case owner
    case authorised
    case legalRepresentative
    
    var ownershipTypeDescs: [OwnershipTypeDesc]? {
        switch self {
        case .owner:
            return [.holder, .owner]
        case .authorised:
            return [.attorney, .authorized]
        case .legalRepresentative:
            return [.representative]
        case .all:
            return nil
        }
    }
    
    func desc() -> String {
        switch self {
        case .all:
            return "pg_select_everyone_pb"
        case .owner:
            return "pg_select_owner_pb"
        case .authorised:
            return "pg_select_authorised_pb"
        case .legalRepresentative:
            return "pg_select_legalrepResentative_pb"
        }
    }
    
    func matchesFor(_ product: OwnershipTypeDesc?) -> Bool {
        guard let typeDescs = ownershipTypeDescs, let productTypeDesc = product else { return true }
        return typeDescs.contains { $0 == productTypeDesc }
    }
}
