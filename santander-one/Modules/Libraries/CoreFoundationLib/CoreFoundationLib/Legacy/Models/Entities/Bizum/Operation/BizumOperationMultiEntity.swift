import SANLegacyLibrary

public struct BizumOperationMultiEntity: DTOInstantiable {
    public let dto: BizumOperationMultiDTO

    public init(_ dto: BizumOperationMultiDTO) {
        self.dto = dto
    }
}
