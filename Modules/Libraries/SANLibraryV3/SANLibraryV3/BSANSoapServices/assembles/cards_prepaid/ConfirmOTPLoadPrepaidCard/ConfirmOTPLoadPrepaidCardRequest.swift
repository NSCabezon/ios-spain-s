import Foundation
public class ConfirmOTPLoadPrepaidCardRequest: BSANSoapRequest <ConfirmOTPLoadPrepaidCardRequestParams, ConfirmOTPLoadPrepaidCardHandler, BSANSoapResponse, ConfirmOTPLoadPrepaidCardParser> {
    
    public static let serviceName = "confCargaTarPrepago_LA"
    
    public override var serviceName: String {
        return ConfirmOTPLoadPrepaidCardRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Recargaecash_la/F_tarsan_recargaecash_la/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <entrada>" +
            "               <token>\(params.otpToken)</token>" +
            "               <ticketOTP>\(params.otpTicket)</ticketOTP>" +
            "               <codigoOTP>\(params.otpCode)</codigoOTP>" +
            "               <contratoTarjeta>" +
            "                   <CENTRO>" +
            "                       <EMPRESA>\(params.cardDTO.contract?.bankCode ?? "")</EMPRESA>" +
            "                       <CENTRO>\(params.cardDTO.contract?.branchCode ?? "")</CENTRO>" +
            "                   </CENTRO>" +
            "                   <PRODUCTO>\(params.cardDTO.contract?.product ?? "")</PRODUCTO>" +
            "                   <NUMERO_DE_CONTRATO>\(params.cardDTO.contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
            "               </contratoTarjeta>" +
            "               <numTarjeta>\(params.cardDTO.PAN ?? "")</numTarjeta>" +
            "               <importeOperacion>" +
            "                   <IMPORTE>\(AmountFormats.getValueForWS(value: params.amountDTO.value))</IMPORTE>" +
            "                   <DIVISA>\(params.amountDTO.currency?.currencyName ?? "")</DIVISA>" +
            "               </importeOperacion>" +
            "               <cuentaAsociada>" +
            "                   <CENTRO>" +
            "                       <EMPRESA>\(params.accountDTO.oldContract?.bankCode ?? "")</EMPRESA>" +
            "                       <CENTRO>\(params.accountDTO.oldContract?.branchCode ?? "")</CENTRO>" +
            "                   </CENTRO>" +
            "                   <PRODUCTO>\(params.accountDTO.oldContract?.product ?? "")</PRODUCTO>" +
            "                   <NUMERO_DE_CONTRATO>\(params.accountDTO.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
            "               </cuentaAsociada>" +
            "               <datosTarjeta>" +
            "                   <canalComercial>\(params.prepaidCardDataDTO.commercialChannel ?? "")</canalComercial>" +
            "                   <saldoActualPrepago>" +
            "                       <IMPORTE>\(AmountFormats.getValueForWS(value: params.prepaidCardDataDTO.currentBalance?.value))</IMPORTE>" +
            "                       <DIVISA>\(params.prepaidCardDataDTO.currentBalance?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </saldoActualPrepago>" +
            "                   <estandarDeReferencia>" +
            "                       <SUBTIPO_DE_PRODUCTO>" +
            "                           <TIPO_DE_PRODUCTO>" +
            "                               <EMPRESA>\(params.prepaidCardDataDTO.referenceStandardDTO?.productSubtypeDTO?.company ?? "")</EMPRESA>" +
            "                               <TIPO_DE_PRODUCTO>\(params.prepaidCardDataDTO.referenceStandardDTO?.productSubtypeDTO?.productType ?? "")</TIPO_DE_PRODUCTO>" +
            "                           </TIPO_DE_PRODUCTO>" +
            "                           <SUBTIPO_DE_PRODUCTO>\(params.prepaidCardDataDTO.referenceStandardDTO?.productSubtypeDTO?.productSubtype ?? "")</SUBTIPO_DE_PRODUCTO>" +
            "                       </SUBTIPO_DE_PRODUCTO>" +
            "                       <CODIGO_DE_ESTANDAR>\(params.prepaidCardDataDTO.referenceStandardDTO?.standardCode ?? "")</CODIGO_DE_ESTANDAR>" +
            "                   </estandarDeReferencia>" +
            "                   <tipoLiquidacion>\(params.prepaidCardDataDTO.liquidationType ?? "")</tipoLiquidacion>" +
            "                   <formaDePago>\(params.prepaidCardDataDTO.paymentMethod ?? "")</formaDePago>" +
            "                   <nomTitular>\(params.prepaidCardDataDTO.holderName ?? "")</nomTitular>" +
            "                   <descNomProdISBAN>\(params.prepaidCardDataDTO.prodNameDescISBAN ?? "")</descNomProdISBAN>" +
            "               </datosTarjeta>" +
            "               <datosPreliq>\(getPreliqDataXML(preliqDataDTO: params.validateLoadPrepaidCardDTO.preliqDataDTO))</datosPreliq>" +
            "           </entrada>" +
            "           <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "           <datosCabecera>" +
            "               <idioma>" +
            "                   <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                   <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "               </idioma>" +
            "               <empresaAsociada>\(params.linkedCompany)</empresaAsociada>" +
            "           </datosCabecera>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
    
    private func getPreliqDataXML(preliqDataDTO: PreliqDataDTO?) -> String{
        guard let preliqDataDTO = preliqDataDTO else{
            return ""
        }
        
        return  "               <conceptoLiq>\(preliqDataDTO.liqConcept ?? "")</conceptoLiq>\n" +
                "               <indTipoCobro>\(preliqDataDTO.chargeTypeInd ?? "")</indTipoCobro>\n" +
                "               <importeComision>\n" +
                "                  <IMPORTE>\(AmountFormats.getValueForWS(value: preliqDataDTO.bankCharge?.value))</IMPORTE>\n" +
                "                  <DIVISA>\(preliqDataDTO.bankCharge?.currency?.currencyName ?? "")</DIVISA>\n" +
                "               </importeComision>\n" +
                "               <importeEstandar>\n" +
                "                  <IMPORTE>\(AmountFormats.getValueForWS(value: preliqDataDTO.standardAmount?.value))</IMPORTE>\n" +
                "                  <DIVISA>\(preliqDataDTO.standardAmount?.currency?.currencyName ?? "")</DIVISA>\n" +
                "               </importeEstandar>\n" +
                "               <importeOperacion>\n" +
                "                  <IMPORTE>\(AmountFormats.getValueForWS(value: preliqDataDTO.operationAmount?.value))</IMPORTE>\n" +
                "                  <DIVISA>\(preliqDataDTO.operationAmount?.currency?.currencyName ?? "")</DIVISA>\n" +
                "               </importeOperacion>\n" +
                "               <importeTeorico>\n" +
                "                  <IMPORTE>\(AmountFormats.getValueForWS(value: preliqDataDTO.notionalAmount?.value))</IMPORTE>\n" +
                "                  <DIVISA>\(preliqDataDTO.notionalAmount?.currency?.currencyName ?? "")</DIVISA>\n" +
                "               </importeTeorico>\n" +
                "               <canalComercial>\(preliqDataDTO.commercialChannel ?? "")</canalComercial>\n" +
                "               <saldoActualPrepago>\n" +
                "                  <IMPORTE>\(AmountFormats.getValueForWS(value: preliqDataDTO.prepaidCurrentBalance?.value))</IMPORTE>\n" +
                "                  <DIVISA>\(preliqDataDTO.prepaidCurrentBalance?.currency?.currencyName ?? "")</DIVISA>\n" +
                "               </saldoActualPrepago>\n" +
                "               <importeTotalOperacion>\n" +
                "                  <IMPORTE>\(AmountFormats.getValueForWS(value: preliqDataDTO.totalOperationAmount?.value))</IMPORTE>\n" +
                "                  <DIVISA>\(preliqDataDTO.totalOperationAmount?.currency?.currencyName ?? "")</DIVISA>\n" +
                "               </importeTotalOperacion>\n" +
                "               <importeCobro>\n" +
                "                  <IMPORTE>\(AmountFormats.getValueForWS(value: preliqDataDTO.receivableAmount?.value))</IMPORTE>\n" +
                "                  <DIVISA>\(preliqDataDTO.receivableAmount?.currency?.currencyName ?? "")</DIVISA>\n" +
                "               </importeCobro>\n" +
                "               <estandarDeReferencia>\n" +
                "                  <SUBTIPO_DE_PRODUCTO>\n" +
                "                     <TIPO_DE_PRODUCTO>\n" +
                "                        <EMPRESA></EMPRESA>\n" +
                "                        <TIPO_DE_PRODUCTO></TIPO_DE_PRODUCTO>\n" +
                "                     </TIPO_DE_PRODUCTO>\n" +
                "                     <SUBTIPO_DE_PRODUCTO>\(preliqDataDTO.referenceStandard?.productSubtypeDTO?.productSubtype ?? "")</SUBTIPO_DE_PRODUCTO>\n" +
                "                  </SUBTIPO_DE_PRODUCTO>\n" +
                "                  <CODIGO_DE_ESTANDAR>\(preliqDataDTO.referenceStandard?.standardCode ?? "")</CODIGO_DE_ESTANDAR>\n" +
                "               </estandarDeReferencia>"
    }
    
}
