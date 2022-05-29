import Foundation

protocol FinancialAgregatorProtocolDataSourceProtocol: RestDataSource {
    func loadFinancialAgregator() throws -> BSANResponse<FinancialAgregatorDTO>
}
