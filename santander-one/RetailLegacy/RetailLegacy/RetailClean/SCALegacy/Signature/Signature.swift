import SANLegacyLibrary
import Operative
import CoreFoundationLib
import CoreDomain

protocol SignatureParamater: SignatureRepresentable, OperativeParameter {}

struct Signature {
    var dto: SignatureDTO
    
    public init(dto: SignatureDTO) {
        self.dto = dto
    }
    
    public init(_ representable: SignatureRepresentable) {
        self.dto = representable as! SignatureDTO
    }
}

extension Signature: SignatureParamater {
    var length: Int? {
        return dto.length
    }
    var positions: [Int]? {
        return dto.positions
    }
    var values: [String]? {
        get {
            return dto.values
        }
        set {
            dto.values = newValue
        }
    }
}

struct SignatureWithToken {
    let magicPhrase: String?
    
    var signature: Signature
    var signatureWithTokenDTO: SignatureWithTokenDTO {
        return SignatureWithTokenDTO(signatureDTO: signature.dto, magicPhrase: magicPhrase)
    }
    
    init?(dto: SignatureWithTokenDTO) {
        guard let signatureDTO = dto.signatureDTO else {
            return nil
        }
        self.magicPhrase = dto.magicPhrase
        self.signature = Signature(dto: signatureDTO)
    }
    
    public init?(_ representable: SignatureWithTokenRepresentable) {
        guard let signatureDTO = representable.signatureRepresentable as? SignatureDTO else {
            return nil
        }
        self.magicPhrase = representable.magicPhrase
        self.signature = Signature(dto: signatureDTO)
    }
}

extension SignatureWithToken: SignatureParamater {
    var length: Int? {
        return signature.length
    }
    var positions: [Int]? {
        return signature.positions
    }
    var values: [String]? {
        get {
            return signature.values
        }
        set {
            signature.values = newValue
        }
    }
}

extension SignatureWithToken: SignatureWithTokenRepresentable {
    public var signatureRepresentable: SignatureRepresentable? {
        return signature as? SignatureRepresentable
    }
}
