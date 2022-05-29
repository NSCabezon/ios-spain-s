import Foundation

public struct ApplePayConfirmationDTO: Codable {
    public let encryptedPassData: Data
    public let activationData: Data
    public let ephemeralPublicKey: Data
    public let wrappedKey: Data?
    
    public init(encryptedPassData: Data, activationData: Data, ephemeralPublicKey: Data, wrappedKey: Data?) {
        self.encryptedPassData = encryptedPassData
        self.activationData = activationData
        self.ephemeralPublicKey = ephemeralPublicKey
        self.wrappedKey = wrappedKey
    }
}
