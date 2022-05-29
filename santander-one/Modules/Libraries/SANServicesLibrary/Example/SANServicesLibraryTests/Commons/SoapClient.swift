//
//  SoapClient.swift
//  SANServicesLibrayTests
//
//  Created by José Carlos Estela Anguita on 20/5/21.
//

import Foundation
import SANServicesLibrary
import CoreDomain

final class SoapSpainClient: NSObject, SoapClient {
    
    struct Response: SoapResponse {
        let body: String
        let data: Data
        let status: Int
    }
    
    func request(_ request: SoapRequest) -> Result<SoapResponse, Error> {
        let group = DispatchGroup()
        guard let url = URL(string: request.url) else { return .failure(ServiceError.unknown) }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        request.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        urlRequest.httpBody = request.body.data(using: String.Encoding.utf8, allowLossyConversion: true)
        urlRequest.httpMethod = "POST"
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        var result: Result<SoapResponse, Error> = .failure(ServiceError.timeout)
        group.enter()
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session.dataTask(with: urlRequest) { data, httpResponse, error in
            defer {
                group.leave()
            }
            let status = (httpResponse as? HTTPURLResponse)?.statusCode ?? 200
            guard let response = data.map({ Response(body: String(data: $0, encoding: .utf8) ?? "", data: $0, status: status) }) else {
                result = error.map({ _ in .failure(ServiceError.timeout) }) ?? .failure(ServiceError.unknown)
                return
            }
            result = .success(response)
        }.resume()
        group.wait()
        return result
    }
}

extension SoapSpainClient: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, challenge.protectionSpace.serverTrust.map(URLCredential.init))
    }
}
