//
//  EnvelopeSoapInterceptor.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 18/5/21.
//

import Foundation
import SANServicesLibrary

struct EnvelopeSoapInterceptor: NetworkRequestInterceptor {
    
    enum EnvelopeType {
        case soapenv
        case vEnvelope
        
        func opening(withRequest request: NetworkRequest, nameSpace: String, facade: String) -> String {
            switch self {
            case .soapenv:
                return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            case .vEnvelope:
                return "<v:Envelope xmlns:v=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:c=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:d=\"http://www.w3.org/2001/XMLSchema\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">"
            }
        }
        
        func close(withRequest request: NetworkRequest) -> String {
            switch self {
            case .soapenv:
                return "</soapenv:Envelope>"
            case .vEnvelope:
                return "</v:Envelope>"
            }
        }
    }
    
    let type: EnvelopeType
    let nameSpace: String
    let facade: String
    
    func interceptRequest(_ request: NetworkRequest) -> NetworkRequest {
        return InterceptedRequest(
            serviceName: request.serviceName,
            url: request.url,
            headers: request.headers,
            method: request.method,
            body: """
            \(type.opening(withRequest: request, nameSpace: nameSpace, facade: facade))
                \(request.body)
            \(type.close(withRequest: request))
            """
        )
    }
}
