import Foundation

public class ConfirmPayOffCardRequest: BSANSoapRequest <ConfirmPayOffCardRequestParams, ConfirmPayOffCardHandler, BSANSoapResponse, ConfirmPayOffCardParser> {
    
    public static let serviceName = "confIngresoPorCtaIngresoCto_LA"
    
    public override var serviceName: String {
        return ConfirmPayOffCardRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Ingresotarjeta_la/F_tarsan_ingresotarjeta_la/internet/"
    }
    
    override var message: String {
        let signatureString: String
        if let signature = params.signatureWithTokenDTO.signatureDTO {
            signatureString = FieldsUtils.getSignatureXml(signatureDTO: signature)
        } else {
            signatureString = ""
        }
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            
            "           <entrada>" +
            XMLHelper.getContractXML(parentKey: "contratoTarjeta",
                                     company: params.cardDTO.contract?.bankCode,
                                     branch: params.cardDTO.contract?.branchCode,
                                     product: params.cardDTO.contract?.product,
                                     contractNumber: params.cardDTO.contract?.contractNumber) +
            XMLHelper.getContractXML(parentKey: "cuentaDeCargo",
                                     company: params.linkedAccountContract?.bankCode,
                                     branch: params.linkedAccountContract?.branchCode,
                                     product: params.linkedAccountContract?.product,
                                     contractNumber: params.linkedAccountContract?.contractNumber) +
            XMLHelper.getAmountXML(parentKey: "importeAIngresar",
                                   importe: AmountFormats.getValueForWS(value: params.amountDTO.value),
                                   divisa: params.amountDTO.currency?.currencyName) +
            "               <numTarjeta>\(params.cardDTO.PAN ?? "")</numTarjeta>" +
            "               <datosFirma>\(signatureString)</datosFirma>" +
            "               <token>\(params.signatureWithTokenDTO.magicPhrase ?? "")</token>" +
            "          </entrada>" +
            
            "          <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            XMLHelper.getHeaderData(language: serviceLanguage(params.languageISO),
                                    dialect: params.dialectISO,
                                    linkedCompany: params.linkedCompany) +
            
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
