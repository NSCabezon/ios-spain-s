import Foundation
public class ActivateCardConfirmationRequest: BSANSoapRequest <ActivateCardConfirmationRequestParams, ActivateCardConfirmationHandler, BSANSoapResponse, ActivateCardConfirmationParser> {
    
    public static let serviceName = "confirmarActivacionTarjeta_LIP"
    
    public override var serviceName: String {
        return ActivateCardConfirmationRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Tarjetas/F_bamobi_tarjetas_lip/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "           <datosCabecera>" +
            "               <version>\(params.version)</version>" +
            "               <terminalID>\(params.terminalId)</terminalID>" +
            "               <idioma>\(serviceLanguage(params.language))</idioma>" +
            "           </datosCabecera>" +
            "           <entrada>" +
            "               <datosValidacion>" +
            "                   <numeroTarj>\((params.cardPAN))</numeroTarj>" +
            "                   <contratoTarjeta>" +
            "                       <PRODUCTO>\(params.cardContractProduct)</PRODUCTO>" +
            "                       <NUMERO_DE_CONTRATO>\(params.cardContractNumber)</NUMERO_DE_CONTRATO>" +
            "                       <CENTRO>" +
            "                           <CENTRO>\(params.cardContractBranchCode)</CENTRO>" +
            "                           <EMPRESA>\(params.cardBankCode)</EMPRESA>" +
            "                       </CENTRO>" +
            "                   </contratoTarjeta>" +
            "                   <fechaCaducidad>\(DateFormats.toString(date: params.cardExpirationDate, output: DateFormats.TimeFormat.YYYYMMDD))</fechaCaducidad>" +
            "               </datosValidacion>" +
            "               <datosFirma>\((FieldsUtils.getSignatureXml(signatureDTO: params.cardSignature)))</datosFirma>" +
            "           </entrada>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
    
}
