import Foundation

public class GetScheduledTransferDetailRequest: BSANSoapRequest<GetScheduledTransferDetailRequestParams, GetScheduledTransferDetailHandler, GetScheduledTransferDetailResponse, GetScheduledTransferDetailParser> {
    
    private static let SERVICE_NAME = "detallePeriodicaDiferidaLa" 
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    public override var serviceName: String {
        return GetScheduledTransferDetailRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "   <soapenv:Body>" +
            "      <v1:\(serviceName) facade=\"\(facade)\">" +
            "       <datosConexion>" +
            "            <idioma>" +
            "               <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "               <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "            </idioma>" +
            "            \(params.userDataDTO.getUserDataWithChannelAndCompanyAndMultiContract)" +
            "         </datosConexion>" +
            "       <entrada>" +
            "           <numeroOrdenCabecera>\(params.numberOrderHeader)</numeroOrdenCabecera>" +
            "               <numOrdenDetalle>" +
            "                 <CENTRO>" +
            "                     <EMPRESA/>" +
            "                     <CENTRO/>" +
            "                  </CENTRO>" +
            "                  <PRODUCTO/>" +
            "                  <NUMERO_DE_ORDEN/>" +
            "               </numOrdenDetalle>" +
            "           <tipoTransferencia>\(params.typeTransfer)</tipoTransferencia>" +
            "           <tipoSeleccion>\(params.typeSelection)</tipoSeleccion>" +
            "           <divisa>\(params.currency)</divisa>" +
            "           <iban>" +
            "                <PAIS>\(params.iban.countryCode)</PAIS>" +
            "                <DIGITO_DE_CONTROL>\(params.iban.checkDigits)</DIGITO_DE_CONTROL>" +
            "                <CODBBAN>\(params.iban.codBban30)</CODBBAN>" +
            "            </iban>" +
            "         </entrada>" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}

public struct GetScheduledTransferDetailRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let numberOrderHeader: String
    public let typeTransfer: String
    public let typeSelection: String
    public let currency: String
    public let iban: IBANDTO
}
