import CoreDomain
import Foundation

public class RemoveScheduledTransferRequest: BSANSoapRequest <RemoveScheduledTransferRequestParams, RemoveScheduledTransferHandler, BSANSoapResponse, RemoveScheduledTransferParser> {
    
    private static let SERVICE_NAME = "bajaPeriodicaDiferidaLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    public override var serviceName: String {
        return RemoveScheduledTransferRequest.SERVICE_NAME
    }
    
    override var message: String {
        let signatureString: String
        if let signature = params.signature.signatureDTO {
            signatureString = FieldsUtils.getSignatureXml(signatureDTO: signature)
        } else {
            signatureString = ""
        }
        
        let toDateFilterString = DateFormats.toString(date: params.dateEndValidity, output: DateFormats.TimeFormat.YYYYMMDD)
        
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "   <soapenv:Body>" +
            "      <v1:\(serviceName) facade=\"\(facade)\">" +
            "        <datosConexion>" +
            "            <idioma>" +
            "             <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "               <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "            </idioma>" +
            "                \(params.userDataDTO.getUserDataWithChannelAndCompanyAndMultiContract)" +
            "        </datosConexion>" +
            "        <entrada>" +
            "           <tokenPasos>\(params.signature.magicPhrase ?? "")</tokenPasos>" +
            "            <importeTransferencia>" +
            "               <IMPORTE>\(params.transferAmount.getDecimalPart())</IMPORTE>" +
            "               <DIVISA>\(params.transferAmount.currency?.currencyName ?? "")</DIVISA>" +
            "            </importeTransferencia>" +
            "            \(signatureString)" +
            "            <numeroOrdenCabecera>\(params.numberOrderHeader)</numeroOrdenCabecera>" +
            "            <tipoTransferencia>\(params.typeTransfer)</tipoTransferencia>" +
            "            <fechaBaja>\(toDateFilterString)</fechaBaja>" +
            "            <contratoOrdenante>" +
            "                <PAIS>\(params.iban.countryCode)</PAIS>" +
            "                <DIGITO_DE_CONTROL>\(params.iban.checkDigits)</DIGITO_DE_CONTROL>" +
            "                <CODBBAN>\(params.iban.codBban30)</CODBBAN>" +
            "            </contratoOrdenante>" +
            "         </entrada>" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}

public struct RemoveScheduledTransferRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    
    public let transferAmount: AmountDTO
    public let signature: SignatureWithTokenDTO
    public let numberOrderHeader: String
    public let typeTransfer: String
    public let dateEndValidity: Date
    public let iban: IBANDTO
}
