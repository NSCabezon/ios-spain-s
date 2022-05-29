import Foundation

public class FinancialAgregatorProtocolDataSource: FinancialAgregatorProtocolDataSourceProtocol {
    
    let sanRestServices: SanRestServices
    public static let SERVICE_NAME = "agregador"
    private let bsanDataProvider: BSANDataProvider
    private let basePath = "/"
    private let headers = [
        "X-Santander-Channel":"RML",
        "Content-Type":"application/json"
    ]
    
    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func loadFinancialAgregator() throws -> BSANResponse<FinancialAgregatorDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + FinancialAgregatorProtocolDataSource.SERVICE_NAME
        do {
            let response: BSANResponse<FinancialAgregatorDTO> = try self.executeRestCallWithoutParams(
                serviceName: FinancialAgregatorProtocolDataSource.SERVICE_NAME,
                serviceUrl: url,
                contentType: .queryString,
                requestType: .get,
                headers: headers,
                responseEncoding: .utf8
            )
            return response
        } catch {
            return BSANOkResponse(Meta.createKO(checkExceptionError(error: error)))
        }
    }
}
