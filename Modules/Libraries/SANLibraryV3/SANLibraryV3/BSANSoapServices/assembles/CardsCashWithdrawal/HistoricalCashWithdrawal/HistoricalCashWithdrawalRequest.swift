import Foundation

public class HistoricalCashWithdrawalRequest: BSANSoapRequest <HistoricalCashWithdrawalRequestParams, HistoricalCashWithdrawalHandler, HistoricalCashWithdrawalResponse, HistoricalCashWithdrawalParser> {
    
    public static let serviceName = "consultarEmisionSacarDinero_LA"
    
    public override var serviceName: String {
        return HistoricalCashWithdrawalRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SADIEL/Sacardineroemi_la/F_sadiel_sacardineroemi_la/internet/"
    }
    
    override var message: String {
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <entrada>" +
            "                   <datosFirma>\(params.cardSignature.signatureDTO != nil ? getSignatureXml(signatureDTO: params.cardSignature.signatureDTO!) : "")</datosFirma>" +
            "                   <token>\(params.cardSignature.magicPhrase ?? "")</token>" +
            "                   <numReg>14</numReg>" +
            "                   <ultNumMensaje></ultNumMensaje>" +
            "                   <descUltFechaHoraPet></descUltFechaHoraPet>" +
            "                   <descUltPAN></descUltPAN>" +
            "                   <descListaActivadorClave></descListaActivadorClave>" +
            XMLHelper.getContractXML(parentKey: "contratoTarjeta", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            "                   <numTarjeta>\(params.PAN)</numTarjeta>" +
            "               </entrada>" +
            "               <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            XMLHelper.getHeaderData(language: serviceLanguage(params.languageISO), dialect: params.dialectISO, linkedCompany: params.linkedCompany) +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
