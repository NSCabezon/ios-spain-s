//
//  WSClientManager.swift
//  SANServicesLibrary
//
//  Created by Hernán Villamil on 30/11/21.
//

public struct NetworkClientManager {
    
    private let client: NetworkClient
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    public func request(_ request: NetworkRequest, requestInterceptors: [NetworkRequestInterceptor], responseInterceptors: [NetworkResponseInterceptor]) throws -> Result<NetworkResponse, Error> {
        let request = requestInterceptors.reduce(request) { request, interceptor in
            return interceptor.interceptRequest(request)
        }
        let result = try self.client.request(request)
        let response: Result<NetworkResponse, Error> = try responseInterceptors.reduce(result) { result, interceptor in
            switch result {
            case .success(let response):
                return try interceptor.interceptResponse(response)
            case .failure:
                return result
            }
        }
        return response
    }
}
