import SwiftyJSON

protocol EasyPayNewPurchaseDataSourceProtocol: RestDataSource {
    func confirmationEasyPay(input: BuyFeesParameters, card: CardDTO) throws -> BSANResponse<Void>
}

public class EasyPayNewPurchaseDataSource: EasyPayNewPurchaseDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let servicePath = "/api/v1/requests/"
    private let serviceName = "newPurchaseInstallments"
    private let headers = ["X-Santander-Channel": "RML"]
    
    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func confirmationEasyPay(input: BuyFeesParameters, card: CardDTO) throws -> BSANResponse<Void> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else { return BSANErrorResponse(nil) }
        let url = source + servicePath + serviceName
        var dictionary = [String : Any]()
        let body = EasyPayNewPurchaseQueryDTO(card: card, input: input)
        dictionary = parseBodyToDictionary(body: body)
        do {
            let request = createRequest(url, dictionary: dictionary)
            if let response = try sanRestServices.executeRestCall(request: request),
               let responseString = (response as? RestJSONResponse)?.message {
                let error = getServiceErrorInfo(response: responseString)
                guard let _ = error.httpCode, let moreInformationError = error.moreInformation else {
                    return BSANOkResponse(Meta.createOk())
                }
                return BSANErrorResponse(Meta.createKO(moreInformationError))
            }
        } catch let error {
            return BSANOkResponse(Meta.createKO(checkExceptionError(error: error)))
        }
        return BSANOkResponse(Meta.createKO("NetworkException"))
    }
    
}

private extension EasyPayNewPurchaseDataSource {
    
    func createRequest(_ url: String, dictionary: [String: Any]) -> RestRequest {
        return RestRequest(serviceName: serviceName,
                           serviceUrl: url,
                           body: Body(bodyParam: dictionary, contentType: .json),
                           queryParams: nil,
                           requestType: .post,
                           headers: headers)
    }
    
    func parseBodyToDictionary(body: EasyPayNewPurchaseQueryDTO) -> [String: Any] {
        let jsonEncoder = JSONEncoder()
        var dictionary = [String : Any]()
        if let json = try? jsonEncoder.encode(body) {
            let jsonResponse = try? JSONSerialization.jsonObject(with: json, options: [])
            if let dict = jsonResponse as? [String : Any] {
                dictionary = dict
            }
        }
        return dictionary
    }
}
