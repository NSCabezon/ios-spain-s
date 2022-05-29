
import CoreDomain

public struct SignatureWithTokenDTO: Codable {
    public var signatureDTO: SignatureDTO?
    public var magicPhrase: String?
    
    enum CodingKeys: String, CodingKey {
        case signatureDTO
        case magicPhrase = "token"
    }
    
    public init() {}
    
    public init(signatureDTO: SignatureDTO?, magicPhrase: String?) {
        self.signatureDTO = signatureDTO
        self.magicPhrase = magicPhrase
    }
    
    public init(signatureRepresentable: SignatureRepresentable?, magicPhrase: String?) {
        self.signatureDTO = signatureRepresentable as? SignatureDTO
        self.magicPhrase = magicPhrase
    }
}

extension SignatureWithTokenDTO: SignatureWithTokenRepresentable {
    public var signatureRepresentable: SignatureRepresentable? {
        return signatureDTO
    }
}

extension SignatureWithTokenDTO: SCARepresentable {
    public var type: SCARepresentableType {
        return .signatureWithToken(self)
    }
}
