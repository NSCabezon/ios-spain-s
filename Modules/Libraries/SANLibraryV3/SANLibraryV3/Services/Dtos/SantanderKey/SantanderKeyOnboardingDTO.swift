import CoreDomain
import Foundation
import SANSpainLibrary

struct SantanderKeyStatusDTO: Codable, SantanderKeyStatusRepresentable {
    let clientStatus: String?
    let otherSKinDevice: String?

    enum CodingKeys: String, CodingKey {
        case clientStatus
        case otherSKinDevice
    }
}

struct SantanderKeyAutomaticRegisterBodyDTO: Codable {
    let publicKey: String?
    let deviceId: String?
    let tokenPush: String?

    enum CodingKeys: String, CodingKey {
        case publicKey
        case deviceId
        case tokenPush
    }
}

struct SantanderKeyAutomaticRegisterResultDTO: Codable, SantanderKeyAutomaticRegisterResultRepresentable {
    let sankeyId: String?

    enum CodingKeys: String, CodingKey {
        case sankeyId
    }
}

struct SantanderKeyRegisterAuthMethodResultDTO: Codable {
    let authMethod: String?
    let sanKeyId: String?
    let cardsListDTO: [SantanderKeyCardDTO]?
    let signPositions: String?
    let signLength: String?
    var valuesDTO: [String]?

    enum CodingKeys: String, CodingKey {
        case authMethod
        case sanKeyId
        case cardsListDTO = "cardsList"
        case signPositions
        case signLength
    }
}

extension SantanderKeyRegisterAuthMethodResultDTO: SantanderKeyRegisterAuthMethodResultRepresentable {
    var cardsList: [SantanderKeyCardRepresentable]? {
        return cardsListDTO
    }
}

extension SantanderKeyRegisterAuthMethodResultDTO: SignatureRepresentable {
    var values: [String]? {
        get {
            valuesDTO
        }
        set(newValue) {
            self.valuesDTO = newValue
        }
    }
    
    
    var positions: [Int]? {
        return signPositions?.compactMap{Int(String($0))}
    }
    var length: Int? {
        guard let signatureLength = signLength else { return nil }
        return Int(signatureLength)
    }
}

struct SantanderKeyCardDTO: Codable {
    let pan: String?
    let cardType: String?
    let description: String?
    let imgDTO: SantanderKeyCardImageDTO?

    enum CodingKeys: String, CodingKey {
        case pan
        case cardType
        case description
        case imgDTO = "img"
    }
}

extension SantanderKeyCardDTO: SantanderKeyCardRepresentable {
    var img: SantanderKeyCardImageRepresentable? {
        return imgDTO
    }
}

struct SantanderKeyCardImageDTO: Codable, SantanderKeyCardImageRepresentable {
    let id: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case url
    }
}

struct SantanderKeyRegisterValidationResultDTO: Codable, SantanderKeyRegisterValidationResultRepresentable {
    let otpReference: String?
    var magicPhraseDTO: String?
    var sendType: String?
    var mobileNumber: String?
}

extension SantanderKeyRegisterValidationResultDTO: OTPValidationRepresentable {
    var magicPhrase: String?
    {
        get {
            magicPhraseDTO
        }
        set(newValue) {
            self.magicPhraseDTO = newValue
        }
    }
    
    var ticket: String? {
        return otpReference
    }
    
    var otpExcepted: Bool {
        false
    }
}

struct SantanderKeyRegisterConfirmationResultDTO: Codable, SantanderKeyRegisterConfirmationResultRepresentable {
    let deviceId: String?

    enum CodingKeys: String, CodingKey {
        case deviceId
    }
}

struct SantanderKeyDetailResultDTO: SantanderKeyDetailResultRepresentable {
    let sanKeyApp: String?
    let deviceAlias: String?
    let deviceModel: String?
    let creationDate: String?
    let deviceCode: String?
    let deviceManu: String?
    let soVersion: String?
    let devicePlatform: String?
}
