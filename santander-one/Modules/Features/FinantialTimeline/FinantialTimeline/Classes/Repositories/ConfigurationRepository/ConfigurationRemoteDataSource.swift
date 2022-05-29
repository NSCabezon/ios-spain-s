//
//  ConfigurationRemoteDataSource.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 11/07/2019.
//

import Foundation

class ConfigurationRemoteDataSource: ConfigurationDataSource {
    
    private let url: URL
    private let restClient: RestClient
    private let authorization: Authorization
    
    init(url: URL, restClient: RestClient, authorization: Authorization) {
        self.url = url
        self.restClient = restClient
        self.authorization = authorization
    }
    
    func fetchConfiguration(completion: @escaping (Result<TimeLineConfiguration, Error>) -> Void) {
        restClient.request(
            host: url.absoluteString,
            path: "",
            method: .get,
            headers: ["Authorization": "Basic aWJhbmtpbmc6MWJhbmsxbmcyMDE5IQ=="],
            params: .none
        ) {
            completion($0.decode())
        }
    }
}
