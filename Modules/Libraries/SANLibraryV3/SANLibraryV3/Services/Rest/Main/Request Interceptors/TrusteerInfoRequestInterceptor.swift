//
//  TrusteerInfoRequestInterceptor.swift
//  SANServicesLibrary
//
//  Created by José María Jiménez Pérez on 28/7/21.
//

import SANSpainLibrary
import CoreDomain
import SANServicesLibrary

struct TrusteerInfoRequestInterceptor: NetworkRequestInterceptor {
    
    let info: TrusteerInfoRepresentable?
    let url: String
    
    func interceptRequest(_ request: NetworkRequest) -> NetworkRequest {
        var body = request.body
        if let info = info {
            body.append("""
        <datosTrusteer>
            <remoteAddr>\(!info.disabledServicesIP.contains(request.serviceName) ? info.remoteAddr: "")</remoteAddr>
            <userAgent>\(info.userAgent)</userAgent>
            <customerSessionId>\(info.customerSessionId)</customerSessionId>
            <url>\(url)</url>
        </datosTrusteer>
        """)
        }
        return InterceptedRequest(
            serviceName: request.serviceName,
            url: request.url,
            headers: request.headers,
            method: "",
            body: body)
    }
}
