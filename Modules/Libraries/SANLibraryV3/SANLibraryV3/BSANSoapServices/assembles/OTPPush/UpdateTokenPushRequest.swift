//

import Foundation

public class UpdateTokenPushRequest: BSANSoapRequest<UpdateTokenRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    static public var serviceName = "actualizaTokenDispositivoLa"
    
    public override var serviceName: String {
        return UpdateTokenPushRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SUPOTE/Altaote_la/F_supote_altaote_la/ACSUPOTEAltaOTE/v1"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                    <entrada>
                        <empresa>\(params.userDataDTO.contract?.bankCode ?? "")</empresa>
                        <idioma>
                            <IDIOMA_ISO>\(serviceLanguage(BSANHeaderData.DEFAULT_LANGUAGE_ISO_SAN_ES))</IDIOMA_ISO>
                            <DIALECTO_ISO>\(BSANHeaderData.DEFAULT_DIALECT_ISO_SAN_ES)</DIALECTO_ISO>
                        </idioma>
                        <contrato>
                            <CENTRO>
                                <EMPRESA>\(params.userDataDTO.contract?.bankCode ?? "")</EMPRESA>
                                <CENTRO>\(params.userDataDTO.contract?.branchCode ?? "")</CENTRO>
                            </CENTRO>
                            <PRODUCTO>\(params.userDataDTO.contract?.product ?? "")</PRODUCTO>
                            <NUMERO_DE_CONTRATO>\(params.userDataDTO.contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                        </contrato>
                        <cliente>
                            <TIPO_DE_PERSONA>\(params.userDataDTO.clientPersonType ?? "")</TIPO_DE_PERSONA>
                            <CODIGO_DE_PERSONA>\(params.userDataDTO.clientPersonCode ?? "")</CODIGO_DE_PERSONA>
                        </cliente>
                        <canal>\(params.userDataDTO.channelFrame ?? "")</canal>
                        <tokenActual>\(params.currentToken)</tokenActual>
                        <tokenNuevo>\(params.newToken)</tokenNuevo>
                    </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
