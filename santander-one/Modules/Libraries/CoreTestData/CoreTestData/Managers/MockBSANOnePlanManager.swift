import SANLegacyLibrary

struct MockBSANOnePlanManager: BSANOnePlanManager {
    func checkOnePlan(ranges: [ProductOneRangeDTO]) throws -> BSANResponse<CustomerContractListDTO> {
        fatalError()
    }
}
