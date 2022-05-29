import Foundation
import CoreDomain

public struct CarbonFootprintIdInputDTO: Codable {
    public var realmId: String? = nil

    public init(realmId: String) {
        self.realmId = realmId
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(realmId, forKey: .realmId)
    }
}

extension CarbonFootprintIdInputDTO: CarbonFootprintIdInputRepresentable {}
