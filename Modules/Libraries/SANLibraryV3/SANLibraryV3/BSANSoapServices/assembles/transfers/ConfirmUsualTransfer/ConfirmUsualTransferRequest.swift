import Foundation
public class ConfirmUsualTransferRequest: BSANSoapRequest <ConfirmUsualTransferRequestParams, ConfirmUsualTransferHandler, ConfirmUsualTransferResponse, ConfirmUsualTransferParser> {
    
    public static let serviceName = "confirmarHabitualSEPA_LA"
    
    public override var serviceName: String {
        return ConfirmUsualTransferRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Transfcobrossepa_la/F_bamobi_transfcobrossepa_la/internet/"
    }

    private var trusteer: String {
        guard let info = params.trusteerInfo else { return "" }
        return getTrusteerData(info, withUrl: "/mobile/transferenciasHabitual")
    }
    
    override var message: String {
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <entrada>" +
            "                   <datosTransf>" +
            XMLHelper.getContractXML(parentKey: "cuentaCargo", company: params.originBankCode, branch: params.originBranchCode, product: params.originProduct, contractNumber: params.originContractNumber) +
            "                       <impTransferencia>" +
            "                           <descParteEntera>\(params.transferAmount?.wholePart ?? "")</descParteEntera>" +
            "                           <descParteDecimal>\(params.transferAmount?.getDecimalPart() ?? "")</descParteDecimal>" +
            "                       </impTransferencia>" +
            "                       <conceptoTransfer>\(params.concept)</conceptoTransfer>" +
            "                   </datosTransf>" +
            "                   <datosFirma>\(FieldsUtils.getSignatureXml(signatureDTO: params.signatureDTO))</datosFirma>" +
            "                   <mailCopia>\(params.beneficiaryMail)</mailCopia>" +
            "                   <aliasBeneficiario>\(params.beneficiary)</aliasBeneficiario>" +
            "                   <cuentaAbono>" +
            "                       <PAIS>\(params.ibandto?.countryCode ?? "")</PAIS>" +
            "                       <DIGITO_DE_CONTROL>\(params.ibandto?.checkDigits ?? "")</DIGITO_DE_CONTROL>" +
            "                       <CODBBAN>\(params.ibandto?.codBban30 ?? "")</CODBBAN>" +
            "                   </cuentaAbono>" +
            "        <tipTransf></tipTransf>" +
            "        <indUrgente>\(params.transferType.getType())</indUrgente> " +
            "               </entrada>" +
            "               <datosConexion>\(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")</datosConexion>" +
            "               <datosCabecera>" +
            "                   <version>\(params.version)</version>" +
            "                   <terminalID>\(params.terminalId)</terminalID>" +
            "                   <idioma>\(serviceLanguage(params.language))</idioma>" +
            "               </datosCabecera>" +
            "               \(trusteer)" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
