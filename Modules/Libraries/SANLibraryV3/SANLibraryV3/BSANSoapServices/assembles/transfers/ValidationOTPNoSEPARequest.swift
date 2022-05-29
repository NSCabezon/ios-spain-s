//

import Foundation

public class ValidationOTPNoSEPARequest: BSANSoapRequest<ValidationOTPNoSEPARequestParams, ValidationOTPNoSEPAHandler, ValidationOTPNoSEPAResponse, ValidationOTPNoSEPAParser> {
    
    private static let SERVICE_NAME = "validacionOTPIntNoSEPA_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Emisioninter_la/F_trasan_emisioninter_la/"
    }
    
    public override var serviceName: String {
        return ValidationOTPNoSEPARequest.SERVICE_NAME
    }
    
    override var message: String {
        
        let accountDestination = params.noSepaTransferInput.beneficiaryAccount.account34
        
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "        <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "        <soapenv:Body>" +
            "           <v1:\(serviceName) facade=\"\(facade)\">" +
            "               <cabecera>" +
            "                   <idioma>" +
            "                       <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                       <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "                   </idioma>" +
            "                   <empresaAsociada>\(params.userDataDTO.company ?? "")</empresaAsociada>" +
            "               </cabecera>" +
            "               <datosConexion>\(params.userDataDTO.clientAndChannelXml)</datosConexion>" +
            "               <entrada>" +
            "                   <importe>" +
            "                       <IMPORTE>\(AmountFormats.getValueForWS(value: params.validationIntNoSepaDTO.impNominalOperacion?.value))</IMPORTE>" +
            "                       <DIVISA>\(params.validationIntNoSepaDTO.impNominalOperacion?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </importe>" +
            "                   \(params.validationIntNoSepaDTO.signature != nil ? getSignatureXml(signatureDTO: params.validationIntNoSepaDTO.signature!) : "")" +
            "                   <token>\(params.validationIntNoSepaDTO.token ?? "")</token>" +
            "                   \(params.userDataDTO.getMultiContract()) " +
            "                   <cuentaOrdenante>" +
            "                       <CENTRO>" +
            "                           <EMPRESA>\(params.noSepaTransferInput.originAccountDTO.oldContract?.bankCode ?? "")</EMPRESA>" +
            "                           <CENTRO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.branchCode ?? "")</CENTRO>" +
            "                       </CENTRO>" +
            "                       <PRODUCTO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.product ?? "")</PRODUCTO>" +
            "                       <NUMERO_DE_CONTRATO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
            "                   </cuentaOrdenante>" +
            "                   <cuentaBeneficiario>\(accountDestination)</cuentaBeneficiario>" +
            "               </entrada>" +
            "        </v1:\(serviceName)>" +
            "        </soapenv:Body>" +
        "        </soapenv:Envelope>"
    }
}

public struct ValidationOTPNoSEPARequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let noSepaTransferInput: NoSEPATransferInput
    public let validationIntNoSepaDTO: ValidationIntNoSepaDTO
}
