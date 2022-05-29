import SwiftyJSON

protocol EasyPayFinanceableListDataSourceProtocol: RestDataSource {
    func getFinanceableList(input: FinanceableListParameters) throws -> BSANResponse<FinanceableMovementsListDTO>
}

public final class EasyPayFinanceableListDataSource: EasyPayFinanceableListDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let servicePath = "/api/v1/easyPay/"
    private let serviceName = "list"
    private let headers = ["X-Santander-Channel": "RML"]
    
    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func getFinanceableList(input: FinanceableListParameters) throws -> BSANResponse<FinanceableMovementsListDTO> {
        let bsanEnvironment = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else { return BSANErrorResponse(nil) }
        let url = source + servicePath + serviceName
        do {
            let request = createRequest(url,
                                        body: createBody(input))
            if let response = try sanRestServices.executeRestCall(request: request),
               let responseString = (response as? RestJSONResponse)?.message {
                if let error = checkServiceError(response: responseString) {
                    return BSANErrorResponse(Meta.createKO(error))
                }
                return BSANOkResponse(FinanceableMovementsListDTO(json: JSON.init(parseJSON: responseString)))
            }
        } catch let error {
            return BSANOkResponse(Meta.createKO(checkExceptionError(error: error)))
        }
        return BSANOkResponse(Meta.createKO("NetworkException"))
    }
}

private extension EasyPayFinanceableListDataSource {
    func createRequest(_ url: String, body: [String: Any]) -> RestRequest {
        return RestRequest(serviceName: serviceName,
                           serviceUrl: url,
                           body: Body(bodyParam: body, contentType: .json),
                           queryParams: nil,
                           requestType: .post,
                           headers: headers,
                           responseEncoding: .utf8)
    }
    
    func createBody(_ input: FinanceableListParameters) -> [String: Any] {
        var body: [String: Any] = ["pan": input.pan,
                                   "easyPay": input.isEasyPay,
                                   "from_date": input.dateFrom ?? "",
                                   "to_date": input.dateTo ?? ""]
        if !input.isEasyPay {
            body["elegibleFinance"] = input.isElegibleFinancing
        }
        return body
    }
}
