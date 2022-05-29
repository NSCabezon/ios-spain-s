import SwiftyJSON
import SANLegacyLibrary

protocol FractionablePurchaseDetailDataSourceProtocol: RestDataSource {
    func getDetail(input: FractionablePurchaseDetailParameters) throws -> BSANResponse<FinanceableMovementDetailDTO>
}

public final class FractionablePurchaseDetailDataSource: FractionablePurchaseDetailDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let servicePath = "/api/v1/easyPay/"
    private let serviceName = "detailsMov"
    private let headers = ["X-Santander-Channel": "RML"]
    
    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func getDetail(input: FractionablePurchaseDetailParameters) throws -> BSANResponse<FinanceableMovementDetailDTO> {
        let bsanEnvironment = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else { return BSANErrorResponse(nil) }
        let url = source + servicePath + serviceName
        let body = createBody(input)
        return try self.executeRestCall(serviceName: serviceName,
                                        serviceUrl: url,
                                        queryParam: nil,
                                        body: Body(bodyParam: body, contentType: .json),
                                        requestType: .post,
                                        headers: headers,
                                        responseEncoding: .utf8)
    }
}

private extension FractionablePurchaseDetailDataSource {
    func createRequest(_ url: String, body: [String: Any]) -> RestRequest {
        return RestRequest(serviceName: serviceName,
                           serviceUrl: url,
                           body: Body(bodyParam: body, contentType: .json),
                           queryParams: nil,
                           requestType: .post,
                           headers: headers,
                           responseEncoding: .utf8)
    }
    
    func createBody(_ input: FractionablePurchaseDetailParameters) -> [String: Any] {
        var body: [String: Any] = ["pan": input.pan,
                                   "movID": input.movID]
        return body
    }
}
