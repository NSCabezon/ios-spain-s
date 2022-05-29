//
//  HeaderDataRequestInterceptor.swift
//  SANServicesLibrary
//
//  Created by Tania Castellano Brasero on 21/10/21.
//

import CoreDomain
import SANSpainLibrary
import SANServicesLibrary

struct HeaderDataRequestInterceptor: NetworkRequestInterceptor {
    
    private let specialLanguage = " io"
    private let defaultTerminalId = "iOS"
    let isPB: Bool
    let specialLanguageServiceNames: [String]
    let version: AppInfoRepresentable?
    
    enum Language {
        case PB
        case noPB
        
        init(isPB: Bool) {
            self = isPB ? .PB : .noPB
        }
        
        var language: String {
            switch self {
            case .PB: return "bp-ES"
            case .noPB: return "es-ES"
            }
        }
    }
    
    func interceptRequest(_ request: NetworkRequest) -> NetworkRequest {
        var body = """
            <datosCabecera>
               <version>\(self.version?.versionName ?? "")</version>
               <terminalID>\(self.defaultTerminalId)</terminalID>
                \(self.generateIdiomaIso(request: request))
            </datosCabecera>
            """
        body.append(request.body)
        return InterceptedRequest(
            serviceName: request.serviceName,
            url: request.url,
            headers: request.headers,
            method: request.method,
            body: body)
    }
}

private extension HeaderDataRequestInterceptor {
    func generateIdiomaIso(request: NetworkRequest) -> String {
        var output = "<idioma>"
        let language: String
        if self.specialLanguageServiceNames.contains(request.serviceName) {
            language = self.specialLanguage
        } else {
            language = Language(isPB: self.isPB).language
        }
        output.append(language)
        output.append("</idioma>")
        return output
    }
}
