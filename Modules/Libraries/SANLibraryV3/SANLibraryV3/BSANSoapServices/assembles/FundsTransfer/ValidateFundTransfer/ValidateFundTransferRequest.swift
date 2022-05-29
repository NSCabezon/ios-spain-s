import Foundation

public class ValidateFundTransferRequest: BSANSoapRequest <ValidateFundTransferRequestParams, ValidateFundTransferHandler, ValidateFundTransferResponse, ValidateFundTransferParser> {
    
    public static let serviceName = "validaTraspasoFondoSAN_LA"
    
    public override var serviceName: String {
        return ValidateFundTransferRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/FONDO1/Suscripfondos_la/F_fondo1_suscripfondos_la/internet/"
    }
    
    override var message: String {
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            
            "           <entrada>" +
                            XMLHelper.getContractXML(parentKey: "contratoDestino",
                                                     company: params.destinationBankCode,
                                                     branch: params.destinationBranchCode,
                                                     product: params.destinationProduct,
                                                     contractNumber: params.destinationContractNumber) +
            "               <tipoTraspasoTotalParcial>\((params.fundTransferType == FundTransferType.typeTotal) ? "T" : "P")</tipoTraspasoTotalParcial>" +
                            XMLHelper.getFundOperationsTypeXML(parentKey: "participacionOImporte",
                                                               fundOperationsType: params.operationsType) +
                            XMLHelper.getAmountXML(parentKey: "importeTraspaso",
                                                   importe: params.amountForWS,
                                                   divisa: params.currency) +
            "               <numParticipaciones>\(params.sharesNumber)</numParticipaciones>" +
                            XMLHelper.getProductTypeAndSubtypeXML(parentKey: "codSubtipoMifid",
                                                                  company: params.originCompany,
                                                                  productType: params.originProductType,
                                                                  productSubType: params.originProductSubType) +
                            XMLHelper.getContractXML(parentKey: "contratoOrigen",
                                                     company: params.originBankCode,
                                                     branch: params.originBranchCode,
                                                     product: params.originProduct,
                                                     contractNumber: params.originContractNumber) +
                            XMLHelper.getAmountXML(parentKey: "importeFondoOrigen",
                                                   importe: params.originAmountValueWS,
                                                   divisa: params.originAmountCurrency) +
            "          </entrada>" +
            
            "          <datosConexion>\(params.userDataDTO.getClientChannelCmcXml)</datosConexion>" +
                        XMLHelper.getHeaderData(language: serviceLanguage(params.language),
                                                dialect: params.dialect,
                                                linkedCompany: BSANHeaderData.DEFAULT_LINKED_COMPANY_SAN_ES_0049) +
            
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
