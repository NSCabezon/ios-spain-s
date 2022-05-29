//
//  ParseSignature.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 30/9/21.
//

import Foundation

public protocol ParseSignature {
    func processSignatureResult(_ response: Any) throws -> SignatureResultEntity
    func processSendMoneySignatureResult(_ error: Any) throws -> SignatureResultEntity
}

public extension ParseSignature {
    func processSignatureResult(_ response: Any) throws -> SignatureResultEntity {
        return .otherError
    }
    
    func processSendMoneySignatureResult(_ error: Any) throws -> SignatureResultEntity {
        return .otherError
    }
}

public enum SignatureResultEntity {
    case ok
    case revoked
    case invalid
    case otpUserExcepted
    case otherError
    case unknown
}
