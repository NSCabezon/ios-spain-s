import SANLegacyLibrary

public final class SavingProductDetailEntity: DTOInstantiable {
    public let dto: SavingProductDTO
    
    public init(_ dto: SavingProductDTO) {
        self.dto = dto
    }
}
