public protocol BSANFinancialAgregatorManager {
    func getFinancialAgregator() throws -> BSANResponse<FinancialAgregatorDTO>
}
