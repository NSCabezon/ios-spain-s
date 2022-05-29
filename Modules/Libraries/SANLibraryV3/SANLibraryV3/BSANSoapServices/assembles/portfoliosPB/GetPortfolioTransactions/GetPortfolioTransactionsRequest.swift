import Foundation
public class GetPortfolioTransactionsRequest: BSANSoapRequest <GetPortfolioTransactionsRequestParams, GetPortfolioTransactionsHandler, GetPortfolioTransactionsResponse, GetPortfolioTransactionsParser> {
    
    public static let serviceName = "listarMovimientosPorFecha_LA"
    private static let customFacade = "ACMOSPCAConsultaPlanes"
    
    public let NUM_LINEA = "10"
    public let SOURCE_CODE = "B"
    public let OPERATION_CODE = "TODO"
    
    public override var serviceName: String {
        return GetPortfolioTransactionsRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/MOSPCA/Consultaplanes_la/F_mospca_consultaplanes_la/internet/"
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
            "      <n3:\(serviceName) xmlns:n3=\"\(nameSpace)\(GetPortfolioTransactionsRequest.customFacade)/v1\" facade=\"\(GetPortfolioTransactionsRequest.customFacade)\">" +
            "           \(params.pagination?.repositionXML ?? "")" +
            "         <datosCabecera>" +
            "           <version>\(params.version)</version>" +
            "           <terminalID>\(params.terminalId)</terminalID>" +
            "           <idioma>" +
            "               <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "               <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "           </idioma>" +
            "        </datosCabecera>" +
            "        <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            "        <entrada>" +
            "           <contrato>" +
            "               <CENTRO>" +
            "                   <EMPRESA>\(empresa)</EMPRESA>" +
            "                   <CENTRO>\(centro)</CENTRO>" +
            "               </CENTRO>" +
            "               <PRODUCTO>\(producto)</PRODUCTO>" +
            "               <NUMERO_DE_CONTRATO>\(numeroContrato)</NUMERO_DE_CONTRATO>" +
            "           </contrato>" +
            "           <numLinea>\(NUM_LINEA)</numLinea>" +
            "           <idCartera>\(params.portfolioId)</idCartera>" +
            "           <nombreValor>\(params.portfolioValueName)</nombreValor>" +
            "           <tipoDeActivo>\(params.portfolioActiveType)</tipoDeActivo>" +
            "           <codigoProcedencia>\(SOURCE_CODE)</codigoProcedencia>" +
            "           <tipoOperacionCombo>\(OPERATION_CODE)</tipoOperacionCombo>" +
            "           \(getDateFilterMessage())" +
            "        </entrada>" +
            "      </n3:\(serviceName)>" +
            "   </v:Body>" +
        "</v:Envelope>";
        
        return returnString
    }
}
