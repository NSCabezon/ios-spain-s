//
//  RestSpainRequest.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 12/5/21.
//

import Foundation
import SANServicesLibrary

struct RestSpainRequest<Query, Body>: NetworkRequest {
    enum BodyParamEncoding {
        case json
        case urlEncoded
    }

    let method: String
    let serviceName: String
    let url: String
    let headers: [String: String]
    let body: String
    
    private init(method: String, serviceName: String, url: String, headers: [String: String], body: String?) {
        self.method = method
        self.serviceName = serviceName
        self.url = url
        self.headers = headers
        self.body = body ?? ""
    }
}

extension RestSpainRequest where Body: Encodable, Query == Void {
    
    init(method: String, serviceName: String, url: String, headers: [String: String] = [:], body: Body, encoding: BodyParamEncoding) {
        self.init(
            method: method,
            serviceName: serviceName,
            url: url,
            headers: headers,
            body: RestSpainRequest.body(for: body, encoding: encoding)
        )
    }
}


extension RestSpainRequest where Body: Encodable, Query: Encodable {
    
    init(method: String, serviceName: String, url: String, headers: [String: String] = [:], query: Query, body: Body, encoding: BodyParamEncoding) {
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = query.queryItems()
        self.init(
            method: method,
            serviceName: serviceName,
            url: urlComponents?.url?.absoluteString ??  url,
            headers: headers,
            body: RestSpainRequest.body(for: body, encoding: encoding)
        )
    }
}

extension RestSpainRequest where Body == Void, Query == Void {
    
    init(method: String, serviceName: String, url: String, headers: [String: String] = [:]) {
        self.init(
            method: method,
            serviceName: serviceName,
            url: url,
            headers: headers,
            body: nil
        )
    }
}

extension RestSpainRequest where Body == Void, Query == Encodable {
    
    init(method: String, serviceName: String, url: String, headers: [String: String] = [:], query: Query) {
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = query.queryItems()
        self.init(
            method: method,
            serviceName: serviceName,
            url: urlComponents?.url?.absoluteString ??  url,
            headers: headers,
            body: nil
        )
    }
}

private extension RestSpainRequest {
    
    static func body<Body: Encodable>(for data: Body, encoding: BodyParamEncoding) -> String? {
        switch encoding {
        case .json:
            let body = try? JSONEncoder().encode(data)
            return body.flatMap({ String(data: $0, encoding: .utf8) })
        case .urlEncoded:
            return data.encodingString()
        }
    }
}

private extension Encodable {
    
    func encodingString() -> String {
        guard let data = try? JSONEncoder().encode(self), let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any], dictionary.keys.count > 0 else {
            return ""
        }
        return dictionary.enumerated().reduce(into: "") { current, next in
            guard let value = next.element.value as? String else { return }
            switch next.offset {
            case 0:
                current += next.element.key + "=" + value
            default:
                current += "&" + next.element.key + "=" + value
            }
        }
    }
    
    func queryItems() -> [URLQueryItem]? {
        guard let data = try? JSONEncoder().encode(self), let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any], dictionary.keys.count > 0 else {
            return nil
        }
        return dictionary.compactMap {
            guard let stringParam = $0.value as? String else { return nil }
            return URLQueryItem(name: $0.key, value: stringParam)
        }
    }
}
