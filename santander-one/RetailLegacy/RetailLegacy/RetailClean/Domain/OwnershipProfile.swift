import SANLegacyLibrary
import CoreDomain

enum OwnershipProfile {
    case all
    case owner
    case authorised
    case representative
    
    var ownershipTypeDescs: [OwnershipTypeDesc]? {
        switch self {
        case .owner:
            return [.holder, .owner]
        case .authorised:
            return [.attorney, .authorized]
        case .representative:
            return [.representative]
        case .all:
            return nil
        }
    }
    
    static func from(list: [OwnershipTypeDesc]?) -> OwnershipProfile {
        guard let list = list, let first = list.first else {
            return .all
        }
        switch first {
        case .holder, .owner:
            return .owner
        case .attorney, .authorized:
            return .authorised
        case .representative:
            return .representative
        case .other:
            return .all
        }
    }
    
    func matchesFor(_ product: GenericProduct) -> Bool {
        guard let typeDescs = ownershipTypeDescs, let productTypeDesc = product.getTipoInterv() else {
            return true
        }
        return typeDescs.contains { $0 == productTypeDesc }
    }
}
