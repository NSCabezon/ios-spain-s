import Foundation
import CoreDomain

public struct CarbonFootprintTokenDTO: Codable {
    public var idToken: String?

    private enum CodingKeys: String, CodingKey {
        case idToken = "token"
    }

    public init(token: String) {
        self.idToken = token
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        idToken = try values.decode(String.self, forKey: .idToken)
    }
}

extension CarbonFootprintTokenDTO: CarbonFootprintTokenRepresentable { }
