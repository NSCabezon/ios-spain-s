//
//  DemoRestClient.swift
//  IB-FinantialTimeline-iOS_Example
//
//  Created by José Carlos Estela Anguita on 05/07/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import FinantialTimeline
import Foundation

class DemoRestClient: RestClient {
    
    var jsonsForPath: [String: String] {
        return [
            "/([0-9+])*/coming/([0-9])*": "coming_timeline_events",
            "/([0-9+])*/previous/([0-9])*": "previous_timeline_events",
            "timeline/event/([A-Za-z0-9_])*": "event_detail",
            "timeline/configuration": "configuration"
        ]
    }
    
    func request(host: String, path: String, method: RestClientHTTPMethod, headers: [String : String], params: RestClientParams, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: host + path) else { return }
        let result = loadFromFile(for: url.path)
        switch result {
        case .failure:
            asyncRequest(method: method.value(), url: url, headers: headers, bodyParams: [:]) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        case .success:
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                completion(result)
            }
        }
    }
    
    // MARK: - Private
    
    private func loadFromFile(for path: String) -> Result<Data, Error> {
        do {
            guard let jsonPath = Bundle.main.path(forResource: jsonsForPath.first(where: { path.range(of: $0.key, options: .regularExpression) != nil })?.value ?? path, ofType: ".json") else {
                return .failure(NSError(domain: "demo.restclient", code: 0, userInfo: [NSLocalizedDescriptionKey: "The file \(path).json couldn't be loaded"]))
            }
            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath), options: .mappedIfSafe)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
    
    private func yyyyMMdd(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    
    private func asyncRequest(method: String, url: URL, headers: [String: String], bodyParams: [String: Codable], completion: @escaping (Swift.Result<Data, Error>) -> Void) {
        let request = urlRequest(method: method, url: url, headers: headers, bodyParams: bodyParams)
        let defaultSession = URLSession(configuration: .default)
        defaultSession.dataTask(with: request) { data, _, error in
            guard let data = data else {
                return completion(.failure(error ?? NSError(domain: "Error", code: 0, userInfo: [:])))
            }
            return completion(.success(data))
        }.resume()
    }
    
    private func urlRequest(method: String, url: URL, headers: [String: String], bodyParams: [String: Codable]) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        return request
    }
}
