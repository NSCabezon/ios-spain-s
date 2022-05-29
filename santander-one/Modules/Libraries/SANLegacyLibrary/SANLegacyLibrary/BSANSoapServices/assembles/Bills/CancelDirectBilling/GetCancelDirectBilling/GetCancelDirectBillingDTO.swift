import Foundation

public struct GetCancelDirectBillingDTO {
    public let tipauto: String
    public let cdinaut: String
    public let signature: SignatureDTO?
    
    public init(tipauto: String, cdinaut: String, signature: SignatureDTO?) {
        self.tipauto = tipauto
        self.cdinaut = cdinaut
        self.signature = signature
    }
}
