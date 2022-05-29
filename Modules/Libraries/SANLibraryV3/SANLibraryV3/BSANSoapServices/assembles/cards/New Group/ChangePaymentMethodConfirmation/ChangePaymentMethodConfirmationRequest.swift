import Foundation

public class ChangePaymentMethodConfirmationRequest: BSANSoapRequest<ChangePaymentMethodConfirmationRequestParams, ChangePaymentMethodConfirmationHandler, ChangePaymentMethodConfirmationResponse, ChangePaymentMethodConfirmationParser> {
    
    public static let SERVICE_NAME = "confirmaCambioFormaPago_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Cambioformapago_la/F_tarsan_cambioformapago_la/internet/"
    }
    
    public override var serviceName: String {
        return ChangePaymentMethodConfirmationRequest.SERVICE_NAME
    }
    
    override var message: String {
        let msg: String =
            "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
                "xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
                "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
                "   <soapenv:Body>" +
                "      <v1:\(serviceName) facade=\"\(facade)\">" +
                "         <entrada>" +
                "            <datosFirma>" +
                //THE SIGNATURE IS BLANK IN THIS SERVICE.
                "            </datosFirma>" +
                "            <importeCuota>" +
                "               <IMPORTE>\(AmountFormats.getDecimalForWS(value: params.selectedAmount.value))</IMPORTE>" +
                "               <DIVISA>\(params.selectedAmount.currency?.currencyName ?? "")</DIVISA>" +
                "            </importeCuota>" +
                "            <formaDePagoActual>\(params.currentPaymentMethod?.rawValue ?? "")</formaDePagoActual>" +
                "            <estandarDeReferencia>" +
                "               <SUBTIPO_DE_PRODUCTO>" +
                "                  <TIPO_DE_PRODUCTO>" +
                "                     <EMPRESA>\(params.referenceStandard.productSubtypeDTO?.company ?? "")</EMPRESA>" +
                "                     <TIPO_DE_PRODUCTO>\(params.referenceStandard.productSubtypeDTO?.productType ?? "")</TIPO_DE_PRODUCTO>" +
                "                  </TIPO_DE_PRODUCTO>" +
                "                  <SUBTIPO_DE_PRODUCTO>\(params.referenceStandard.productSubtypeDTO?.productSubtype ?? "")</SUBTIPO_DE_PRODUCTO>" +
                "               </SUBTIPO_DE_PRODUCTO>" +
                "               <CODIGO_DE_ESTANDAR>\(params.referenceStandard.standardCode ?? "")</CODIGO_DE_ESTANDAR>" +
                "            </estandarDeReferencia>" +
                "            <codigoMercado>\(params.marketCode)</codigoMercado>" +
                "<!--SE OBTENDRÁ DEL COMBO DE FORMA DE PAGO -->" +
                "            <formaDePagoNueva>\(params.newPaymentMethodDTO.paymentMethod?.rawValue ?? "")</formaDePagoNueva>" +
                "            <contratoTarjeta>" +
                "               <CENTRO>" +
                "                  <EMPRESA>\(params.bankCode)</EMPRESA>" +
                "                  <CENTRO>\(params.branchCode)</CENTRO>" +
                "               </CENTRO>" +
                "               <PRODUCTO>\(params.product)</PRODUCTO>" +
                "               <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>" +
                "            </contratoTarjeta>" +
                "           <tipoLiquidacionActual>\(params.currentSettlementType)</tipoLiquidacionActual>" +
                "<!--SE OBTENDRÁ DEL COMBO DE FORMA DE PAGO -->" +
                "            <tipoLiquidacionNueva>\(params.newPaymentMethodDTO.liquidationType ?? "")</tipoLiquidacionNueva>" +
                "            <modalidadFormaPagoActual>\(params.currentPaymentMethodMode)</modalidadFormaPagoActual>" +
                "            <codigoMercadoOculto>\(params.hiddenMarketCode)</codigoMercadoOculto>" +
                "            <modalidadFormaPagoOculto>\(params.hiddenPaymentMethodMode)</modalidadFormaPagoOculto>" +
                "            <idRangoFP>\(params.newPaymentMethodDTO.idRangeFP ?? "")</idRangoFP>" +
                "            <estandarReferenciaOculto>" +
                "               <SUBTIPO_DE_PRODUCTO>" +
                "                  <TIPO_DE_PRODUCTO>" +
                "                     <EMPRESA>\(params.hiddenReferenceStandard.productSubtypeDTO?.company ?? "")</EMPRESA>" +
                "                     <TIPO_DE_PRODUCTO>\(params.hiddenReferenceStandard.productSubtypeDTO?.productType ?? "")</TIPO_DE_PRODUCTO>" +
                "                  </TIPO_DE_PRODUCTO>" +
                "                  <SUBTIPO_DE_PRODUCTO>\(params.hiddenReferenceStandard.productSubtypeDTO?.productSubtype ?? "")</SUBTIPO_DE_PRODUCTO>" +
                "               </SUBTIPO_DE_PRODUCTO>" +
                "               <CODIGO_DE_ESTANDAR>\(params.hiddenReferenceStandard.standardCode ?? "")</CODIGO_DE_ESTANDAR>" +
                "            </estandarReferenciaOculto>" +
                "         </entrada>" +
                "            <datosCabecera>" +
                "                <idioma>" +
                "                    <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
                "                    <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
                "                </idioma>" +
                "                <empresaAsociada>\(params.linkedCompany)</empresaAsociada>" +
                "            </datosCabecera>" +
                "            <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
                "      </v1:\(serviceName)>" +
                "   </soapenv:Body>" +
                "</soapenv:Envelope>"
        
        return msg
    }
}
