import SANLegacyLibrary

public final class BizumResponseInfoEntity: DTOInstantiable {
    public let dto: BizumResponseInfoDTO
    
    public init(_ dto: BizumResponseInfoDTO) {
        self.dto = dto
    }
}
