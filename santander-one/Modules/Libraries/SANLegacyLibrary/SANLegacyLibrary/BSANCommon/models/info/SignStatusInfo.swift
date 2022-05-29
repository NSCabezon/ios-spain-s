import Foundation

public class SignStatusInfo: Codable {

    public static func createSignStatus(signatureDataDTO: SignatureDataDTO) -> SignStatusInfo {
        return SignStatusInfo(signatureDataDTO)
    }

    public let signatureDataDTO: SignatureDataDTO
    public var justActivated: Bool

    private init(_ signatureDataDTO: SignatureDataDTO) {
        self.signatureDataDTO = signatureDataDTO
        self.justActivated = false
    }

}
