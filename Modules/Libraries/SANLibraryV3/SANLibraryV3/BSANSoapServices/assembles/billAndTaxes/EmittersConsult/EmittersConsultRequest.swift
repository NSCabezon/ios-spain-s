//

import Foundation

public class EmittersConsultRequest: BSANSoapRequest<EmittersConsultRequestParams, EmittersConsultHandler, EmittersConsultResponse, EmittersConsultParser> {
    
    static public var serviceName = "consultaEmisoras_LA"
    
    public override var serviceName: String {
        return EmittersConsultRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/PARETR/Pagorecibos_la/F_paretr_pagorecibos_la/"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)\(facade)/v1">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                  <v1:\(serviceName) facade="\(facade)">
                     <datosConexion>
                        <cliente>
                           <TIPO_DE_PERSONA>\(params.userDataDTO.clientPersonType ?? "")</TIPO_DE_PERSONA>
                           <CODIGO_DE_PERSONA>\(params.userDataDTO.clientPersonCode ?? "")</CODIGO_DE_PERSONA>
                        </cliente>
                        <cuentaCargo>
                           <CENTRO>
                              <EMPRESA>\(params.bankCode)</EMPRESA>
                              <CENTRO>\(params.branchCode)</CENTRO>
                           </CENTRO>
                           <PRODUCTO>\(params.product)</PRODUCTO>
                           <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>
                        </cuentaCargo>
                        <idioma>
                           <IDIOMA_ISO>\(serviceLanguage(BSANHeaderData.DEFAULT_LANGUAGE_ISO_SAN_ES))</IDIOMA_ISO>
                           <DIALECTO_ISO>\(BSANHeaderData.DEFAULT_DIALECT_ISO_SAN_ES)</DIALECTO_ISO>
                        </idioma>
                        <empresa>\(params.bankCode)</empresa>
                        <canal>\(params.userDataDTO.channelFrame ?? "")</canal>
                     </datosConexion>
                     <entrada>
                        <codigoEmisora>\(params.emitterCode)</codigoEmisora>
                        <nombreEmisora>\(params.emitterName)</nombreEmisora>
                     </entrada>
                    \(params.paginationXML)
                  </v1:\(serviceName)>
               </soapenv:Body>
            </soapenv:Envelope>
        """
    }
}
