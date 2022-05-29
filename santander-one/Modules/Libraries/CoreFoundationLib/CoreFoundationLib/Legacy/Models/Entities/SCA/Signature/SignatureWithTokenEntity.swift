//
//  SignatureWithTokenEntity.swift
//  Models
//
//  Created by Juan Carlos López Robles on 3/4/21.
//

import Foundation
import SANLegacyLibrary
import CoreDomain

public class SignatureWithTokenEntity {
    
    public let magicPhrase: String?
    public var signature: SignatureRepresentable
    public var signatureWithTokenDTO: SignatureWithTokenDTO {
        return SignatureWithTokenDTO(signatureRepresentable: signature, magicPhrase: magicPhrase)
    }
    
    var signatureRepresentable: SignatureRepresentable?
    
    public init?(_ dto: SignatureWithTokenDTO) {
        guard let signatureDTO = dto.signatureDTO else {
            return nil
        }
        self.magicPhrase = dto.magicPhrase
        self.signature = signatureDTO
    }
    
    public init?(_ representable: SignatureWithTokenRepresentable) {
        guard let signatureDTO = representable.signatureRepresentable as? SignatureDTO else {
            return nil
        }
        self.signatureRepresentable = signatureDTO
        self.magicPhrase = representable.magicPhrase
        self.signature = signatureDTO
    }
}

extension SignatureWithTokenEntity: SignatureRepresentable {
    public var length: Int? {
        return signature.length
    }
    
    public var positions: [Int]? {
        return signature.positions
    }
    
    public var values: [String]? {
        get {
            return signature.values
        }
        set {
            signature.values = newValue
        }
    }
}

extension SignatureWithTokenEntity: SCA {
    public func prepareForVisitor(_ visitor: SCACapable) {
        (visitor as? SCASignatureWithTokenCapable)?.prepareForSignatureWithToken(self)
    }
}
