import SANLegacyLibrary
import CoreDomain

public struct Manager: DTOInstantiable {
    
    public let dto: ManagerDTO
    
    public init(_ dto: ManagerDTO) {
        self.dto = dto
    }
    
    public var codGest: String {
        return dto.codGest ?? ""
    }
    
    public var nameGest: String {
        return dto.nameGest ?? ""
    }
    
    public var formattedName: String {
        let formatter = PersonNameComponentsFormatter()
        guard let managerName = dto.nameGest?.capitalized,
              let components = formatter.personNameComponents(from: managerName)
        else { return dto.nameGest?.capitalized ?? "" }
        formatter.style = .medium
        return formatter.string(from: components)
    }
    
    public var portfolio: String {
        return dto.portfolio ?? ""
    }
    
    public var phone: String {
        return dto.phone?.tlfFormatted() ?? ""
    }
    
    public var email: String {
        return dto.email ?? ""
    }
    
    public var relativeImageUrl: String {
        return "apps/SAN/imgGP/\(codGest).jpg"
    }
}

extension Manager: Equatable {
    public static func == (lhs: Manager, rhs: Manager) -> Bool {
        return lhs.nameGest == rhs.nameGest
    }
}
