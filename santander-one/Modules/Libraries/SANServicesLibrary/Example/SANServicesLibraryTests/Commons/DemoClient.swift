//
//  DemoClient.swift
//  SANServicesLibrayTests
//
//  Created by José Carlos Estela Anguita on 28/5/21.
//

import SANServicesLibrary


struct DemoClient {
    
    private struct DemoResponse: RestResponse, SoapResponse {
        let body: String
        let data: Data
        let status: Int
    }
    
    let demoResponses: [String: Int]
    
    private func demoResponse(for serviceName: String) -> String {
        return "\(self.demoResponses[serviceName] ?? 0)"
    }
    
    private func request(serviceName: String, fileExtension: String) -> Result<DemoResponse, Error> {
        guard
            let path = Bundle(for: QuickSetup.self).path(forResource: serviceName, ofType: fileExtension),
            let data = FileManager.default.contents(atPath: path)
        else {
            return .failure(ServiceError.unknown)
        }
        return .success(DemoResponse(body: String(data: data, encoding: .utf8) ?? "", data: data, status: 200))
    }
}

extension DemoClient: RestClient {
    
    func request(_ request: RestRequest) -> Result<RestResponse, Error> {
        return self.request(serviceName: request.serviceName, fileExtension: "json").map { respose in
            let json = try? JSONSerialization.jsonObject(with: respose.data, options: .allowFragments) as? [String: Any]
            let demo = json?["12345678z"] as? [String: Any]
            let data = demo?[self.demoResponse(for: request.serviceName)].flatMap({ try? JSONSerialization.data(withJSONObject: $0, options: .fragmentsAllowed) })
            return DemoResponse(body: String(data: data ?? Data(), encoding: .utf8) ?? "", data: data ?? Data(), status: 200)
        }
    }
}

extension DemoClient: SoapClient {
    
    func request(_ request: SoapRequest) -> Result<SoapResponse, Error> {
        return self.request(serviceName: request.serviceName, fileExtension: "xml").map { respose in
            let xml = XMLDecoder(data: respose.data)
                .decode(key: "datos")?
                .decode(key: "id12345678z")?
                .decode(key: "respuesta" + self.demoResponse(for: request.serviceName))?
                .xml()
            return DemoResponse(body: xml ?? "", data: xml?.data(using: .utf8) ?? Data(), status: 200)
        }
    }
}
