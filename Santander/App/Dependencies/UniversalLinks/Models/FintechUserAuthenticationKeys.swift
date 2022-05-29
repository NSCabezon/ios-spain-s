import Foundation
import Ecommerce

struct FintechUserAuthenticationKeys: Codable, FintechUserAuthenticationRepresentable {
    let clientId: String?
    let responseType: String?
    let state: String?
    let scope: String?
    let redirectUri: String?
    let magicPhrase: String?

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case responseType = "response_type"
        case state = "state"
        case scope = "scope"
        case redirectUri = "redirect_uri"
        case magicPhrase = "SOS-JWT-TOKEN"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.clientId = try container.decodeIfPresent(String.self, forKey: .clientId)
        self.responseType = try container.decodeIfPresent(String.self, forKey: .responseType)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)
        self.scope = try container.decodeIfPresent(String.self, forKey: .scope)
        self.redirectUri = try container.decodeIfPresent(String.self, forKey: .redirectUri)
        self.magicPhrase = try container.decodeIfPresent(String.self, forKey: .magicPhrase)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(responseType, forKey: .responseType)
        try container.encode(state, forKey: .state)
        try container.encode(scope, forKey: .scope)
        try container.encode(redirectUri, forKey: .redirectUri)
        try container.encode(magicPhrase, forKey: .magicPhrase)
    }
}
