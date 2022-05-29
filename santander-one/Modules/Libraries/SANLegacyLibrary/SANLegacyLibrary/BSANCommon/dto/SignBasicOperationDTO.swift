//
//  SignBasicOperationDTO.swift
//  SANLegacyLibrary
//
//  Created by Rubén Márquez Fernández on 4/5/21.
//

import Foundation

public struct SignBasicOperationDTO: Codable {
    public let magicPhrase: String
    public var signatureData: SignatureData?
    public let otpData: OtpData?
    public let informationStepCurrentSignature: InformationStepCurrentSignature?
    
    enum CodingKeys: String, CodingKey {
        case magicPhrase = "token"
        case signatureData
        case otpData
        case informationStepCurrentSignature
    }
}

public struct SignatureData: Codable {
    public let length: String
    public let positions: String
    public var values: [String]?
}

public struct InformationStepCurrentSignature: Codable {
    public let lastStep: String
    public let typeSignature: String?
}

public struct OtpData: Codable {
    public let xmlOperative: String
    public let codeOTP: String?
    public let ticketOTP: String
    public let company: String
    public let language: String
    public let channel: String
    public let contract: String
}
