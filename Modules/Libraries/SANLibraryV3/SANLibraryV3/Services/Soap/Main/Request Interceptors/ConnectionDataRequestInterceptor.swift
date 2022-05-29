//
//  ConnectionDataRequestInterceptor.swift
//  SANServicesLibrary
//
//  Created by José María Jiménez Pérez on 29/7/21.
//

import CoreDomain
import SANServicesLibrary

struct ConnectionDataRequestInterceptor: NetworkRequestInterceptor {
    
    private let specialLanguage = " io"
    public let isPB: Bool
    public let userDataTypes: [UserDataType]
    public let specialLanguageServiceNames: [String]
    
    enum LanguageIso {
        case privateBanking
        case noPB
        
        init(isPB: Bool) {
            self = isPB ? .privateBanking : .noPB
        }
        
        var dialectISO: String {
            switch self {
            case .privateBanking: return "ES"
            case .noPB: return "ES"
            }
        }
        
        var languageISO: String {
            switch self {
            case .privateBanking: return "bp"
            case .noPB: return "es"
            }
        }
    }
    
    enum UserDataType {
        case withChannelAndCompanyAndMultiContract(userData: UserDataRepresentable)
        case withChannelAndCompany(userData: UserDataRepresentable)
        case withMarcoChannelAndCompanyAndMultiContract(userData: UserDataRepresentable)
        case withChannelAndCompanyAndCustomContract(userData: UserDataRepresentable, contract: ContractRepresentable)
        
        var xml: String {
            switch self {
            case .withChannelAndCompanyAndMultiContract(let userData):
                return """
                    <cliente>
                        <TIPO_DE_PERSONA>\(userData.clientPersonType ?? "")</TIPO_DE_PERSONA>
                        <CODIGO_DE_PERSONA>\(userData.clientPersonCode ?? "")</CODIGO_DE_PERSONA>
                    </cliente>
                    <canal>\(userData.channelFrame ?? "")</canal>
                    <empresa>\(userData.company ?? "")</empresa>
                    <contratoMulticanal>
                        <CENTRO>
                            <EMPRESA>\(userData.contractRepresentable?.bankCode ?? "")</EMPRESA>
                            <CENTRO>\(userData.contractRepresentable?.branchCode ?? "")</CENTRO>
                        </CENTRO>
                        <PRODUCTO>\(userData.contractRepresentable?.product ?? "")</PRODUCTO>
                        <NUMERO_DE_CONTRATO>\(userData.contractRepresentable?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                    </contratoMulticanal>
                    """
            case .withChannelAndCompany(let userData):
                return """
                    <cliente>
                        <TIPO_DE_PERSONA>\(userData.clientPersonType ?? "")</TIPO_DE_PERSONA>
                        <CODIGO_DE_PERSONA>\(userData.clientPersonCode ?? "")</CODIGO_DE_PERSONA>
                    </cliente>
                    <canal>\(userData.channelFrame ?? "")</canal>
                    <empresa>\(userData.company ?? "")</empresa>
                    """
            case .withMarcoChannelAndCompanyAndMultiContract(let userData):
                return """
                    <empresa>\(userData.company ?? "")</empresa>
                        <cliente>
                            <TIPO_DE_PERSONA>\(userData.clientPersonType ?? "")</TIPO_DE_PERSONA>
                            <CODIGO_DE_PERSONA>\(userData.clientPersonCode ?? "")</CODIGO_DE_PERSONA>
                        </cliente>
                    <canalMarco>\(userData.channelFrame ?? "")</canalMarco>
                    <contratoMulticanal>
                        <CENTRO>
                            <EMPRESA>\(userData.contractRepresentable?.bankCode ?? "")</EMPRESA>
                            <CENTRO>\(userData.contractRepresentable?.branchCode ?? "")</CENTRO>
                        </CENTRO>
                        <PRODUCTO>\(userData.contractRepresentable?.product ?? "")</PRODUCTO>
                        <NUMERO_DE_CONTRATO>\(userData.contractRepresentable?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                    </contratoMulticanal>
                    """
            case .withChannelAndCompanyAndCustomContract(let userData, let contract):
                return """
                    <cliente>
                        <TIPO_DE_PERSONA>\(userData.clientPersonType ?? "")</TIPO_DE_PERSONA>
                        <CODIGO_DE_PERSONA>\(userData.clientPersonCode ?? "")</CODIGO_DE_PERSONA>
                    </cliente>
                    <canal>\(userData.channelFrame ?? "")</canal>
                    <empresa>\(userData.company ?? "")</empresa>
                    <contrato>
                        <CENTRO>
                            <EMPRESA>\(contract.bankCode ?? "")</EMPRESA>
                            <CENTRO>\(contract.branchCode ?? "")</CENTRO>
                        </CENTRO>
                        <PRODUCTO>\(contract.product ?? "")</PRODUCTO>
                        <NUMERO_DE_CONTRATO>\(contract.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                    </contrato>
                """
            }
        }
    }
    
    func interceptRequest(_ request: NetworkRequest) -> NetworkRequest {
        var body = """
            <datosConexion>
                <idioma>
                    \(self.generateIdiomaIso(request: request))
                    <DIALECTO_ISO>\(LanguageIso(isPB: self.isPB).dialectISO)</DIALECTO_ISO>
                </idioma>
                \(userDataTypes.reduce("", {"""
                                                \($0)
                                                \($1.xml)
                                                """
                }))
            </datosConexion>
            """
        body.append(request.body ?? "")
        return InterceptedRequest(
            serviceName: request.serviceName,
            url: request.url,
            headers: request.headers,
            method: request.method,
            body: body)
    }
}

private extension ConnectionDataRequestInterceptor {
    func generateIdiomaIso(request: NetworkRequest) -> String {
        var output = "<IDIOMA_ISO>"
        let language: String
        if self.specialLanguageServiceNames.contains(request.serviceName) {
            language = self.specialLanguage
        } else {
            language = LanguageIso(isPB: self.isPB).languageISO
        }
        output.append(language)
        output.append("</IDIOMA_ISO>")
        return output
    }
}
