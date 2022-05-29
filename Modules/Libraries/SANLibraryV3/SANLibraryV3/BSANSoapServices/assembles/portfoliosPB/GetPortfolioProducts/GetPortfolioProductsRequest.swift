import Foundation
public class GetPortfolioProductsRequest: BSANSoapRequest <GetPortfolioProductsRequestParams, GetPortfolioProductsHandler, GetPortfolioProductsResponse, GetPortfolioProductsParser> {
    
    public static let serviceName = "consultarCartera_LA"
    private static let customFacade = "ACMOSPCAConsultaCartera";

    public override var serviceName: String {
        return GetPortfolioProductsRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/MOSPCA/Consultacartera_la/F_mospca_consultacartera_la/internet/"
    }
    
    override var message: String {
        let empresa = params.userDataDTO.contract?.bankCode ?? ""
        let centro = params.userDataDTO.contract?.branchCode ?? ""
        let producto = params.userDataDTO.contract?.product ?? ""
        let numeroContrato = params.userDataDTO.contract?.contractNumber ?? ""
        
        let returnString = "<v:Envelope " +
            "xmlns:v=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "xmlns:c=\"http://schemas.xmlsoap.org/soap/encoding/\" " +
            "xmlns:d=\"http://www.w3.org/2001/XMLSchema\" " +
            "xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\">" +
            "   <v:Header>\(getSecurityHeader(params.token))</v:Header>" +
            "   <v:Body>" +
            "      <n3:\(serviceName) xmlns:n3=\"\(nameSpace)\(GetPortfolioProductsRequest.customFacade)/v1\" facade=\"\(GetPortfolioProductsRequest.customFacade)\">" +
            "         <entrada>" +
            "            <idCartera>\(params.portfolioId)</idCartera>" +
            "            <contrato>" +
            "               <CENTRO>" +
            "                   <EMPRESA>\(empresa)</EMPRESA>" +
            "                   <CENTRO>\(centro)</CENTRO>" +
            "               </CENTRO>" +
            "               <PRODUCTO>\(producto)</PRODUCTO>" +
            "               <NUMERO_DE_CONTRATO>\(numeroContrato)</NUMERO_DE_CONTRATO>" +
            "            </contrato>" +
            "            <indTipoCartera>\(params.portfolioTypeInd)</indTipoCartera>" +
            "         </entrada>" +
            "         <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            "          <datosCabecera>" +
            "             <version>\(params.version)</version>" +
            "             <terminalID>\(params.terminalId)</terminalID>" +
            "             <idioma>" +
            "                 <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                 <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "             </idioma>" +
            "          </datosCabecera>" +
            "      </n3:\(serviceName)>" +
            "   </v:Body>" +
        "</v:Envelope>";

        return returnString
    }
}
