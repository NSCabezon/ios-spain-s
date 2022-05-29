import Foundation
import SANLegacyLibrary

public class BSANFinancialAgregatorManagerImplementation: BSANBaseManager, BSANFinancialAgregatorManager {
    private let sanRestServices: SanRestServices
    
    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getFinancialAgregator() throws -> BSANResponse<FinancialAgregatorDTO> {
        let storedFinancialAgregatorDTO = try bsanDataProvider.get(\.financialAgregatorDTO)
        guard storedFinancialAgregatorDTO != nil else {
            return try callFinancialAgregatorService()
        }
        return BSANOkResponse(storedFinancialAgregatorDTO)
    }
}

private extension BSANFinancialAgregatorManagerImplementation {
    func callFinancialAgregatorService() throws -> BSANResponse<FinancialAgregatorDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        guard let _ = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let datasource = FinancialAgregatorProtocolDataSource(
            sanRestServices: self.sanRestServices,
            bsanDataProvider: bsanDataProvider
        )
        let response = try datasource.loadFinancialAgregator()
        if let data = try response.getResponseData() {
            bsanDataProvider.store(data)
        }
        return response
    }
}
