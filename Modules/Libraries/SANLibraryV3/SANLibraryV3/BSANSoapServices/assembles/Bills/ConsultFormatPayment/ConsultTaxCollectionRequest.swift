//

import Foundation

public class ConsultTaxCollectionRequest: BSANSoapRequest<ConsultTaxCollectionRequestParams, ConsultTaxCollectionHandler, ConsultTaxCollectionResponse, ConsultTaxCollectionParser> {
    
    static public var serviceName = "consultaFormatos_LA"
    
    public override var serviceName: String {
        return ConsultTaxCollectionRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/PARETR/Pagorecibos_la/F_paretr_pagorecibos_la/ACPARETRPagosRecibos/v1"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
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
        <EMPRESA>\(params.accountDTO.oldContract?.bankCode ?? "")</EMPRESA>
        <CENTRO>\(params.accountDTO.oldContract?.branchCode ?? "")</CENTRO>
              </CENTRO>
        <PRODUCTO>\(params.accountDTO.oldContract?.product ?? "")</PRODUCTO>
        <NUMERO_DE_CONTRATO>\(params.accountDTO.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
           </cuentaCargo>
           <idioma>
        <IDIOMA_ISO>\(params.language)</IDIOMA_ISO>
        <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
           </idioma>
           <empresa>\(params.userDataDTO.company ?? "")</empresa>
           <canal>\(params.userDataDTO.channelFrame ?? "")</canal>
        </datosConexion>
        <entrada>
            <codigoEmisora>\(params.emitterCode ?? "")</codigoEmisora>
            <identificadorProducto>\(params.productIdentifier ?? "")</identificadorProducto>
            <codigoTipoRecaudacion>\(params.collectionTypeCode ?? "")</codigoTipoRecaudacion>
            <codigoRecaudacion>\(params.collectionCode ?? "")</codigoRecaudacion>
        </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
