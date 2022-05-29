import Foundation
import CoreDomain

public struct CarbonFootprintDataInputDTO: Codable {
    public var firstName: String?
    public var lastName: String?
    public var contract: String?
    
    public init(firstName: String,
                lastName: String,
                contract: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.contract = contract
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(contract, forKey: .contract)
    }
}

extension CarbonFootprintDataInputDTO: CarbonFootprintDataInputRepresentable {}
