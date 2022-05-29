//
//  AuthorizationSoapInterceptor.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 18/5/21.
//

import Foundation
import SANServicesLibrary

struct AuthorizationSoapInterceptor: NetworkRequestInterceptor {
    
    let token: String
    
    func interceptRequest(_ request: NetworkRequest) -> NetworkRequest {
        return InterceptedRequest(
            serviceName: request.serviceName,
            url: request.url,
            headers: request.headers,
            method: request.method,
            body: """
            <soapenv:Header>
                <wsse:Security SOAP-ENV:actor="http://www.isban.es/soap/actor/wssecurityB64" SOAP-ENV:mustUnderstand="1" S12:role="wsssecurity" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:S12="http://www.w3.org/2003/05/soap-envelope" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
                    <wsse:BinarySecurityToken xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" wsu:Id="SSOToken" ValueType="esquema" EncodingType="hwsse:Base64Binary">\(self.token)</wsse:BinarySecurityToken>
                </wsse:Security>
            </soapenv:Header>
            \(request.body)
            """
        )
    }
}
