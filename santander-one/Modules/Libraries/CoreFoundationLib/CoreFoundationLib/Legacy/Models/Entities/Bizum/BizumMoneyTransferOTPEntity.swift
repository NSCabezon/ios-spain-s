import SANLegacyLibrary

public final class BizumMoneyTransferOTPEntity: DTOInstantiable {
    public let dto: BizumMoneyTransferOTPDTO
    
    public init(_ dto: BizumMoneyTransferOTPDTO) {
        self.dto = dto
    }
}
