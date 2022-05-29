import Foundation
public class ValidateUnloadPrepaidCardRequest: BSANSoapRequest <ValidateUnloadPrepaidCardRequestParams, ValidateUnloadPrepaidCardHandler, ValidateUnloadPrepaidCardResponse, ValidateUnloadPrepaidCardParser> {
    
    public static let serviceName = "validaDescargaTarPrepago_LA"
    
    public override var serviceName: String {
        return ValidateUnloadPrepaidCardRequest.serviceName
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
            "               <token>\(params.prepaidCardDataDTO.token ?? "")</token>" +
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
    
}
