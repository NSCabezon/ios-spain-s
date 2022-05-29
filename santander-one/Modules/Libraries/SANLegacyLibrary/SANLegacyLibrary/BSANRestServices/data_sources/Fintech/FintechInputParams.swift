import Foundation

public struct FintechUserAuthenticationInputParams: Codable {
    let clientId: String?
    let redirectUri: String?
    let responseType: String?
    let scope: String?
    let state: String?
    let magicPhrase: String?

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case redirectUri = "redirect_uri"
        case responseType = "response_type"
        case scope
        case state
        case magicPhrase = "SOS-JWT-TOKEN"
    }
    
    public init(
        clientId: String?,
        responseType: String?,
        state: String?,
        scope: String?,
        redirectUri: String?,
        magicPhrase: String?) {
        self.clientId = clientId
        self.responseType = responseType
        self.state = state
        self.scope = scope
        self.redirectUri = redirectUri
        self.magicPhrase = magicPhrase
    }
}

public struct FintechUserInfoAccessKeyParams: Codable {
    let authenticationType: String?
    let documentType: String?
    let documentNumber: String?
    let magic: String?
    let ip: String? = "0.0.0.0"
    
    enum CodingKeys: String, CodingKey {
        case authenticationType
        case documentType
        case documentNumber
        case magic = "password"
        case ip
    }

    public init(
        authenticationType: String?,
        documentType: String?,
        documentNumber: String?,
        magic: String?) {
        self.authenticationType = authenticationType
        self.documentType = documentType
        self.documentNumber = documentNumber
        self.magic = magic
    }
}

public struct FintechUserInfoFootprintParams: Codable {
    let authenticationType: String?
    let documentType: String?
    let documentNumber: String?
    let deviceMagicPhrase: String?
    let footprint: String?
    let ip: String? = "0.0.0.0"
    
    enum CodingKeys: String, CodingKey {
        case authenticationType
        case documentType
        case documentNumber
        case deviceMagicPhrase = "deviceToken"
        case footprint
        case ip
    }

    public init(
        authenticationType: String?,
        documentType: String?,
        documentNumber: String?,
        deviceMagicPhrase: String?,
        footprint: String?) {
        self.authenticationType = authenticationType
        self.documentType = documentType
        self.documentNumber = documentNumber
        self.deviceMagicPhrase = deviceMagicPhrase
        self.footprint = footprint
    }
}
