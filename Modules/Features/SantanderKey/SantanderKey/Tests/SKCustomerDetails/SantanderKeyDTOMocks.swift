//
//  SantanderKeyDTOMocks.swift
//  CoreTestData
//
//  Created by David Gálvez Alonso on 19/4/22.
//

import CoreDomain
import Foundation
import SANSpainLibrary

struct SantanderKeyStatusDTOMock: Codable, SantanderKeyStatusRepresentable {
    let clientStatus: String?
    let otherSKinDevice: String?

    enum CodingKeys: String, CodingKey {
        case clientStatus
        case otherSKinDevice
    }
}

struct SantanderKeyAutomaticRegisterBodyDTOMock: Codable {
    let publicKey: String?
    let deviceId: String?
    let tokenPush: String?

    enum CodingKeys: String, CodingKey {
        case publicKey
        case deviceId
        case tokenPush
    }
}

struct SantanderKeyAutomaticRegisterResultDTOMock: Codable, SantanderKeyAutomaticRegisterResultRepresentable {
    let sankeyId: String?

    enum CodingKeys: String, CodingKey {
        case sankeyId
    }
}

struct SantanderKeyRegisterAuthMethodResultDTOMock: Codable {
    let authMethod: String?
    let sanKeyId: String?
    let cardsListDTO: [SantanderKeyCardDTOMock]?
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

extension SantanderKeyRegisterAuthMethodResultDTOMock: SantanderKeyRegisterAuthMethodResultRepresentable {
    var cardsList: [SantanderKeyCardRepresentable]? {
        return cardsListDTO
    }
}

extension SantanderKeyRegisterAuthMethodResultDTOMock: SignatureRepresentable {
    var values: [String]? {
        get {
            valuesDTO
        }
        set(newValue) {
            self.valuesDTO = newValue
        }
    }
    
    var positions: [Int]? {
        return signPositions?.compactMap { Int(String($0)) }
    }
    
    var length: Int? {
        guard let signatureLength = signLength else { return nil }
        return Int(signatureLength)
    }
}

struct SantanderKeyCardDTOMock: Codable {
    let pan: String?
    let cardType: String?
    let description: String?
    let imgDTO: SantanderKeyCardImageDTOMock?

    enum CodingKeys: String, CodingKey {
        case pan
        case cardType
        case description
        case imgDTO = "img"
    }
}

extension SantanderKeyCardDTOMock: SantanderKeyCardRepresentable {
    var img: SantanderKeyCardImageRepresentable? {
        return imgDTO
    }
}

struct SantanderKeyCardImageDTOMock: Codable, SantanderKeyCardImageRepresentable {
    let id: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case url
    }
}

struct SantanderKeyRegisterValidationResultDTOMock: Codable, SantanderKeyRegisterValidationResultRepresentable {
    let otpReference: String?
    var magicPhraseDTO: String?

    enum CodingKeys: String, CodingKey {
        case otpReference
    }
}

extension SantanderKeyRegisterValidationResultDTOMock: OTPValidationRepresentable {
    var magicPhrase: String? {
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

struct SantanderKeyRegisterConfirmationResultDTOMock: Codable, SantanderKeyRegisterConfirmationResultRepresentable {
    let deviceId: String?

    enum CodingKeys: String, CodingKey {
        case deviceId
    }
}

struct SantanderKeyDetailResultDTOMock: SantanderKeyDetailResultRepresentable {
    let sanKeyApp: String?
    let deviceAlias: String?
    let deviceModel: String?
    let creationDate: String?
    let deviceCode: String?
    let deviceManu: String?
    let soVersion: String?
    let devicePlatform: String?
}
