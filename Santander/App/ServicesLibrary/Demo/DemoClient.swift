//
//  RestDemoClient.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 17/5/21.
//

import CoreFoundationLib
import SANServicesLibrary
import Fuzi

struct DemoClient {
    
    var demoResponses: [String: Int] {
        return ["confirmaDiferidasSepaLa": 0, "check-payment": 1]
    }
    
    enum ResponseType: String {
        case json
        case xml
    }
    
    var demoResponseTypes: [String: ResponseType] {
        return ["confirmaDiferidasSepaLa": .xml, "check-payment": .json]
    }
    
    private func demoResponse(for serviceName: String) -> String {
        return "\(self.demoResponses[serviceName] ?? 0)"
    }
    
    private func responseType(for serviceName: String) -> ResponseType {
        return self.demoResponseTypes[serviceName] ?? .json
    }
    
    private struct DemoResponse: NetworkResponse {
        let body: String
        let data: Data
        let status: Int
    }
    
    private func request(serviceName: String, fileExtension: String) -> Result<DemoResponse, Error> {
        guard
            let path = Bundle.main.url(forResource: serviceName, withExtension: fileExtension),
            let data = try? Data(contentsOf: path)
        else {
            return .failure(RepositoryError.unknown)
        }
        return .success(DemoResponse(body: String(data: data, encoding: .utf8) ?? "", data: data, status: 200))
    }
    
    private func handleXml(_ string: String, answerNumber: Int) -> DemoResponse {
        guard let document = try? XMLDocument(string: string),
              let answers = document.root?.firstChild(tag: "id12345678Z"),
              answerNumber < answers.children.count
        else {
            return DemoResponse(body: "", data: Data(), status: 500)
        }
        let body = answers.children[answerNumber].children[0].rawXML
        let data = body.data(using: .utf8)
        return DemoResponse(body: body, data: data ?? Data(), status: 200)
    }
}

extension DemoClient: NetworkClient {
    func request(_ request: NetworkRequest) -> Result<NetworkResponse, Error> {
        return self.request(serviceName: request.serviceName, fileExtension: self.responseType(for: request.serviceName).rawValue).map { respose in
            switch self.responseType(for: request.serviceName) {
            case .json:
                let json = try? JSONSerialization.jsonObject(with: respose.data, options: .allowFragments) as? [String: Any]
                let demo = json?["12345678z"] as? [String: Any]
                let data = demo?[self.demoResponse(for: request.serviceName)].flatMap({ try? JSONSerialization.data(withJSONObject: $0, options: .fragmentsAllowed) })
                return DemoResponse(body: String(data: data ?? Data(), encoding: .utf8) ?? "", data: data ?? Data(), status: 200)
            case .xml: return self.handleXml(respose.body, answerNumber: Int(self.demoResponse(for: request.serviceName))!)
            }
            
        }
    }
}
