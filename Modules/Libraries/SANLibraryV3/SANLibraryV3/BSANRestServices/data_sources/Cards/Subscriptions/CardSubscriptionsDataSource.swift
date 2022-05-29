//
//  CardSubscriptionsDataSource.swift
//  SANLibraryV3
//
//  Created by alvola on 24/02/2021.
//

protocol CardSubscriptionsDataSourceProtocol: RestDataSource {
    func getFinanceableList(input: SubscriptionsListParameters) throws -> BSANResponse<CardSubscriptionsListDTO>
    func getSubscriptionsHistorical(input: SubscriptionsHistoricalInputParams) throws -> BSANResponse<CardSubscriptionsHistoricalListDTO>
    func getSubscriptionsGraphData(input: SubscriptionsGraphDataInputParams) throws -> BSANResponse<CardSubscriptionsGraphDataDTO>
    func activateSubscription(magicPhrase: String, instaId: String) throws -> BSANResponse<Void>
    func deactivateSubscription(magicPhrase: String, instaId: String) throws -> BSANResponse<Void>
}

public final class CardSubscriptionsDataSource: CardSubscriptionsDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let servicePath = "/api/v1/movireta/subscriptions/"
    private let subscriptionListServiceName = "query-subscriptions"
    private let subscriptionHistoricalServiceName = "monthly-details"
    private let subscriptionGraphDataServiceName = "monthly-history"
    private let activateServiceName = "activate"
    private let deactivateServiceName = "suspend"
    private let headers = ["X-Santander-Channel": "RML"]

    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }

    func getFinanceableList(input: SubscriptionsListParameters) throws -> BSANResponse<CardSubscriptionsListDTO> {
        let bsanEnvironment = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else { return BSANErrorResponse(nil) }
        let url = source + servicePath + subscriptionListServiceName
        let body = createFinanciableBody(input: input)
        return try self.executeRestCall(serviceName: subscriptionListServiceName,
                                        serviceUrl: url,
                                        queryParam: nil,
                                        body: Body(bodyParam: body, contentType: .json),
                                        requestType: .post,
                                        headers: headers,
                                        responseEncoding: .utf8)
    }
    
    func getSubscriptionsHistorical(input: SubscriptionsHistoricalInputParams) throws -> BSANResponse<CardSubscriptionsHistoricalListDTO> {
        let bsanEnvironment = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else { return BSANErrorResponse(nil) }
        let url = source + servicePath + subscriptionHistoricalServiceName
        let body = self.paramsDictionary(for: input)
        return try self.executeRestCall(serviceName: subscriptionHistoricalServiceName,
                                        serviceUrl: url,
                                        queryParam: nil,
                                        body: Body(bodyParam: body, contentType: .json),
                                        requestType: .post,
                                        headers: headers,
                                        responseEncoding: .utf8)
    }
    
    func getSubscriptionsGraphData(input: SubscriptionsGraphDataInputParams) throws -> BSANResponse<CardSubscriptionsGraphDataDTO> {
        let bsanEnvironment = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else { return BSANErrorResponse(nil) }
        let url = source + servicePath + subscriptionGraphDataServiceName
        let body = self.paramsDictionary(for: input)
        return try self.executeRestCall(serviceName: subscriptionGraphDataServiceName,
                                        serviceUrl: url,
                                        queryParam: nil,
                                        body: Body(bodyParam: body, contentType: .json),
                                        requestType: .post,
                                        headers: headers,
                                        responseEncoding: .utf8)
    }
    
    func activateSubscription(magicPhrase: String, instaId: String) throws -> BSANResponse<Void> {
        let microURL = try self.getBSANEnvironment()
        guard let source = microURL else { return BSANErrorResponse(nil) }
        let url: String = String(format: "%@%@x-pay-status/tokens/%@", source, servicePath, self.activateServiceName)
        let activateHeaders = ["X-Santander-Channel": "RML", "X-Clientid": "MULMOV"]

        let response = try self.sanRestServices.executeRestCall(
            request: RestRequest(
                serviceName: self.activateServiceName,
                serviceUrl: url,
                body: self.getActivateOrDeactivateBody(magicPhrase: magicPhrase, instaId: instaId),
                queryParams: nil,
                requestType: .post,
                headers: activateHeaders
            )
        )
        if let response = response as? RestJSONResponse {
            if response.httpCode == 204 {
                return BSANOkResponse(nil)
            } else {
                return BSANOkResponse(Meta.createKO(response.message ?? "NetworkException"))
            }
        }
        return BSANOkResponse(Meta.createKO("NetworkException"))
    }
    
    func deactivateSubscription(magicPhrase: String, instaId: String) throws -> BSANResponse<Void> {
        let microURL = try self.getBSANEnvironment()
        guard let source = microURL else { return BSANErrorResponse(nil) }
        let url: String = String(format: "%@%@x-pay-status/tokens/%@", source, servicePath, self.deactivateServiceName)
        let deactivateHeaders = ["X-Santander-Channel": "RML", "X-Clientid": "MULMOV"]

        let response = try self.sanRestServices.executeRestCall(
            request: RestRequest(
                serviceName: self.deactivateServiceName,
                serviceUrl: url,
                body: self.getActivateOrDeactivateBody(magicPhrase: magicPhrase, instaId: instaId),
                queryParams: nil,
                requestType: .post,
                headers: deactivateHeaders
            )
        )
        if let response = response as? RestJSONResponse {
            if response.httpCode == 204 {
                return BSANOkResponse(nil)
            } else {
                return BSANOkResponse(Meta.createKO(response.message ?? "NetworkException"))
            }
        }
        return BSANOkResponse(Meta.createKO("NetworkException"))
    }
    
}

private extension CardSubscriptionsDataSource {
    func createFinanciableBody(input: SubscriptionsListParameters) -> [String: Any] {
        var body: [String : Any] = ["cdgenti":"",
                                    "tipclien": input.clientType,
                                    "numclie": input.clientCode,
                                    "fecdesde": input.dateFrom,
                                    "fechasta": input.dateTo,
                                    "estado": ""]
        if let pan = input.pan {
            body["pan"] = pan
        }
        return body
    }

    func getBSANEnvironment() throws -> String? {
        try self.bsanDataProvider.getEnvironment().microURL
    }

    func getActivateOrDeactivateBody(magicPhrase: String, instaId: String) -> Body? {
        let body = Body(
            bodyParam: ["token": magicPhrase,
                        "insta_id": instaId],
            contentType: .json
        )
        return body
    }
}
