//

import Foundation

public struct BizumSignPositionInfoDTO: Codable {
    public let errorCode: String
}

public struct BizumSignPositionsDTO: Codable {
    public let info: BizumSignPositionInfoDTO
    public let positions: String
    public let signatureLength: Int
    public let magicPhrase: String
    
    enum CodingKeys: String, CodingKey {
        case info
        case positions
        case signatureLength
        case magicPhrase = "token"
    }
    
    public var signature: SignatureWithTokenDTO {
        var signatureDTO = SignatureDTO()
        signatureDTO.positions = DTOParser.safePositions(self.positions)
        signatureDTO.length = self.signatureLength
        return SignatureWithTokenDTO(signatureDTO: signatureDTO, magicPhrase: self.magicPhrase)
    }
}
