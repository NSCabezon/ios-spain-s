import SANLegacyLibrary

struct MockBSANFinancialAgregatorManager: BSANFinancialAgregatorManager {
    func getFinancialAgregator() throws -> BSANResponse<FinancialAgregatorDTO> {
        fatalError()
    }
}
