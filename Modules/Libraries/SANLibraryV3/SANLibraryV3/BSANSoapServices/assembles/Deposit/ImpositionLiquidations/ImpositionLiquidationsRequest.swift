import Foundation

public class ImpositionLiquidationsRequest: BSANSoapRequest<ImpositionLiquidationsRequestParams, ImpositionLiquidationsHandler, ImpositionLiquidationsResponse, ImpositionLiquidationsParser> {

    public static let serviceName = "listaLiquidImposicion_LA"
    public static let serviceNamePagination = "listaLiquidImposicionRepos_LA"

    public override var serviceName: String {
        if params.pagination == nil {
            return ImpositionLiquidationsRequest.serviceName
        } else {
            return ImpositionLiquidationsRequest.serviceNamePagination
        }
    }

    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Depositos/F_bamobi_depositos_la/internet/"
    }

    override var message: String {
        let bankCode = params.bankCode
        let branchCode = params.branchCode
        let product = params.product
        let contractNumber = params.contractNumber
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa

        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
                "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
                "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
                "    <soapenv:Body>" +
                "       <v1:\(serviceName) facade=\"\(facade)\">" +
                "           <entrada>" +
                "               <datosAux>" +
                "                   <!-- Primera consulta serian 15 ultimos dias-->" +
                getDateFilterMessage() +
                "                   <subcontratoImposicion>" +
                "                       <CONTRATO>" +
                "                           <CENTRO>" +
                "                               <EMPRESA>\(bankCode)</EMPRESA>" +
                "                               <CENTRO>\(branchCode)</CENTRO>" +
                "                           </CENTRO>" +
                "                           <PRODUCTO>\(product)</PRODUCTO>" +
                "                           <NUMERO_DE_CONTRATO>\(contractNumber)</NUMERO_DE_CONTRATO>" +
                "                       </CONTRATO>" +
                "                       <SUBCONTRATO>\(params.subContractString)</SUBCONTRATO>" +
                "                   </subcontratoImposicion>" +
                "               </datosAux>" +
                "               <divisa>\(params.currency)</divisa>" +
                "           </entrada>" +
                "           \(params.pagination?.repositionXML ?? "")" +
                "           <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
                "           <datosCabecera>" +
                "               <version>\(params.version)</version>" +
                "               <terminalID>\(params.terminalId)</terminalID>" +
                "               <idioma>\(serviceLanguage(params.language))</idioma>" +
                "           </datosCabecera>" +
                "       </v1:\(serviceName)>" +
                "    </soapenv:Body>" +
                "</soapenv:Envelope>"
        return returnString
    }
}
