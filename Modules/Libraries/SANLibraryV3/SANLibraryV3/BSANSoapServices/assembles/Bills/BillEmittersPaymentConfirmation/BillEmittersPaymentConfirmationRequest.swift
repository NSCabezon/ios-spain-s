//

import Foundation

class BillEmittersPaymentConfirmationRequest: BSANSoapRequest<BillEmittersPaymentConfirmationRequestParams, BillEmittersPaymentConfirmationHandler, BillEmittersPaymentConfirmationResponse, BillEmittersPaymentConfirmationParser> {
    
    static var serviceName = "confirmaPagoNuevoRecibo_LA"
    
    override var serviceName: String {
        return BillEmittersPaymentConfirmationRequest.serviceName
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
                <EMPRESA>\(params.account.oldContract?.bankCode ?? "")</EMPRESA>
                <CENTRO>\(params.account.oldContract?.branchCode ?? "")</CENTRO>
                      </CENTRO>
                <PRODUCTO>\(params.account.oldContract?.product ?? "")</PRODUCTO>
                <NUMERO_DE_CONTRATO>\(params.account.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                   </cuentaCargo>
                   <idioma>
                <IDIOMA_ISO>\(params.language)</IDIOMA_ISO>
                <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
                   </idioma>
                   <empresa>\(params.userDataDTO.company ?? "")</empresa>
                   <canal>\(params.userDataDTO.channelFrame ?? "")</canal>
                </datosConexion>
                <firma>\(getSignatureXmlFormatP(signatureDTO: params.signature))</firma>
                <entrada>
                   <importe>
                      <IMPORTE>\(AmountFormats.getValueForWS(value: params.amount.value))</IMPORTE>
                      <DIVISA>\(params.amount.currency?.currencyName ?? "")</DIVISA>
                   </importe>
                   <codigoEmisora>\(params.emitterCode)</codigoEmisora>
                   <identificadorProducto>\(params.productIdentifier)</identificadorProducto>
                   <codigoTipoRecaudacion>\(params.collectionTypeCode)</codigoTipoRecaudacion>
                   <codigoRecaudacion>\(params.collectionCode)</codigoRecaudacion>
                   <datosRecibo>\(billData)</datosRecibo>
                </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
    
    var billData: String {
        return params.billData
            .map {
                let substring = String($0.prefix(50))
                guard substring.count < 50 else { return substring }
                return substring.completeRightCharacter(size: 50, char: " ")
            }
            .joined(separator: "")
    }
}
