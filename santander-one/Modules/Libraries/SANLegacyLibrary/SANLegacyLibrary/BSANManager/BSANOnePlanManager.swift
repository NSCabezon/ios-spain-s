public protocol BSANOnePlanManager {
    func checkOnePlan(ranges: [ProductOneRangeDTO]) throws -> BSANResponse<CustomerContractListDTO>
}
