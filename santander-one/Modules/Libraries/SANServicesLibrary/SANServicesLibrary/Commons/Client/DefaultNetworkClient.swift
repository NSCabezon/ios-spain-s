//
//  SoapSpainClient.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 11/5/21.
//

import Foundation
import CoreFoundationLib

final public class DefaultNetworkClient: NSObject {

    private let compilation: CompilationProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
        super.init()
    }
    
    struct Response: NetworkResponse {
        let data: Data
        let status: Int
        var body: String {
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    private func request(url: String, headers: [String: String], body: String?, method: String) throws -> Result<Response, Error> {
        let group = DispatchGroup()
        guard let url = URL(string: url) else { return .failure(RepositoryError.unknown) }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        urlRequest.httpBody = body?.data(using: String.Encoding.utf8, allowLossyConversion: true)
        urlRequest.httpMethod = method
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        var result: Result<Response, Error> = .failure(RepositoryError.timeout)
        var response: HTTPURLResponse?
        group.enter()
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session.dataTask(with: urlRequest) { data, httpResponse, error in
            defer {
                group.leave()
            }
            response = httpResponse as? HTTPURLResponse
            guard let status = (httpResponse as? HTTPURLResponse)?.statusCode, error == nil,
                let dataTaskResponse = data.map({ Response(data: $0, status: status) }) else {
                result = error.map({ .failure(RepositoryError.error($0)) }) ?? .failure(RepositoryError.unknown)
                return
            }
            result = .success(dataTaskResponse)
        }.resume()
        group.wait()
        if let statusCode = response?.statusCode {
            try self.evaluateStatusCode(statusCode)
        }
        return result
    }
}

extension DefaultNetworkClient: NetworkClient {
    public func request(_ request: NetworkRequest) throws -> Result<NetworkResponse, Error> {
        return try self.request(
            url: request.url,
            headers: request.headers,
            body: request.body,
            method: request.method
        ).map({ $0 })
    }
}

extension DefaultNetworkClient: URLSessionDelegate {
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if compilation.isTrustInvalidCertificateEnabled && challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            completionHandler(.useCredential, challenge.protectionSpace.serverTrust.map(URLCredential.init))
        } else {
            var secResult = SecTrustResultType.invalid
            guard
                challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                let serverTrust = challenge.protectionSpace.serverTrust,
                SecTrustEvaluate(serverTrust, &secResult) == errSecSuccess,
                let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0),
                self.certificatesForSSLPinning().contains(serverCert)
            else {
                return self.reject(with: completionHandler)
            }
            self.accept(with: serverTrust, completionHandler)
        }
    }
}

private extension DefaultNetworkClient {
    
    struct Certificate {
        
        let filePath: String
        
        func secCertificate() -> SecCertificate? {
            guard
                let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.bundlePath + "/" + filePath)),
                let certificate = SecCertificateCreateWithData(nil, data as CFData)
            else {
                return nil
            }
            return certificate
        }
    }
    
    func certificatesForSSLPinning() -> [SecCertificate] {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath) else { return [] }
        let certificates: [SecCertificate] = files.compactMap { file in
            guard file.suffix(4) == ".cer" else { return nil }
            let certificate = Certificate(filePath: file)
            let secCertificate = certificate.secCertificate()
            return secCertificate
        }
        return certificates
    }
    
    func reject(with completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) {
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    func accept(with serverTrust: SecTrust, _ completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) {
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
    
    func evaluateStatusCode(_ statusCode: Int) throws {
        switch statusCode {
        case URLError.networkConnectionLost.rawValue: throw CoreExceptions.network
        default: break
        }
    }
}
