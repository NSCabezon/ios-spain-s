//
//  ValidateSanKeyTransferOTPRequest.swift
//  SANLibraryV3
//
//  Created by Andres Aguirre Juarez on 25/10/21.
//

import Foundation

class ValidateSanKeyTransferOTPRequest: BSANSoapRequest <ValidateSanKeyTransferOTPRequestParams, ValidateSanKeyTransferOTPHandler, ValidateSanKeyTransferOTPResponse, ValidateSanKeyTransferOTPParser> {
    
    public static let serviceName = "sanKeyValidarNacionalOTPSEPA_LA"
    
    public override var serviceName: String {
        return ValidateSanKeyTransferOTPRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Transfcobrossepa_la/F_bamobi_transfcobrossepa_la/internet/"
    }
    
    override var message: String {
        
        let signature: String
        if let signatureDTO = params.signatureDTO {
            signature = FieldsUtils.getSignatureXml(signatureDTO: signatureDTO)
        } else {
            signature = ""
        }

        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <entrada>" +
            "                   <datosTransf>" +
            "                       <cuentaAbonoPais>\(params.ibandto.countryCode)</cuentaAbonoPais>" +
            "                       <cuentaAbonoDigitoControl>\(params.ibandto.checkDigits)</cuentaAbonoDigitoControl>" +
            "                       <cuentaAbonoCodBBan>\(params.ibandto.codBban30)</cuentaAbonoCodBBan>" +
            XMLHelper.getContractXML(parentKey: "cuentaCargo", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            "                       <impTransferencia>" +
            "                           <descParteEntera>\(params.transferAmount.wholePart)</descParteEntera>" +
            "                           <descParteDecimal>\(params.transferAmount.getDecimalPart())</descParteDecimal>" +
            "                       </impTransferencia>" +
            "                   </datosTransf>" +
            "                   <datosFirma>\(signature)</datosFirma>" +
            "                   <tokenPasos>\(params.tokenPasos)</tokenPasos>" +
            "                   <footPrint>\(params.footPrint)</footPrint>" +
            "                   <deviceToken>\(params.deviceToken)</deviceToken>" +
            "               </entrada>" +
            "               <datosConexion>\(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")</datosConexion>" +
            "               <datosCabecera>" +
            "                   <version>\(params.version)</version>" +
            "                   <terminalID>\(params.terminalId)</terminalID>" +
            "                   <idioma>\(serviceLanguage(originalLanguage: params.language, dialectISO: params.dialectISO))</idioma>" +
            "               </datosCabecera>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
