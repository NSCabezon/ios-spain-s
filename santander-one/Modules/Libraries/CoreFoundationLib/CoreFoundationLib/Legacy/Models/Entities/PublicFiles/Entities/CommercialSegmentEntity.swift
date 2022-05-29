// Draws the logo
import CoreDomain

public enum SemanticSegmentTypeEntity {
    case spb, select, universitarios, retail
    
    func semanticSegmentType() -> SemanticSegmentType {
        switch self {
        case .spb:
            return .spb
        case .select:
            return .select
        case .universitarios:
            return .universitarios
        case .retail:
            return .retail
        }
    }
}

public struct CommercialSegmentEntity {
    
    public let dto: CommercialSegmentsDTO
    public let contact: ContactSegmentEntity?
    
    public var commercialSegmentType: String? {
        return dto.commercialType
    }
    
    public var topBarBackground: SemanticSegmentTypeDTO? {
        return dto.semanticSegmentType
    }

    public var isSelect: Bool {
        return topBarBackground == .select
    }
    
    public var isUniversity: Bool {
        return topBarBackground == .universitarios
    }
    
    public var semanticSegment: SemanticSegmentTypeEntity {
        switch dto.semanticSegmentType {
        case .select:
            return .select
        case .universitarios:
            return .universitarios
        case .retail, .none:
            return .retail
        }
    }
    
    public init(dto: CommercialSegmentsDTO) {
        self.dto = dto
        self.contact = ContactSegmentEntity(dto: dto.contact)
    }
}

extension CommercialSegmentEntity: CommercialSegmentRepresentable {
    public var contactRepresentable: ContactSegmentRepresentable? {
        return contact
    }
    
    public var topBarBackgroundSegment: String? {
        return topBarBackground?.rawValue
    }
    
    public var semanticSegmentType: SemanticSegmentType {
        return semanticSegment.semanticSegmentType()
    }
}
