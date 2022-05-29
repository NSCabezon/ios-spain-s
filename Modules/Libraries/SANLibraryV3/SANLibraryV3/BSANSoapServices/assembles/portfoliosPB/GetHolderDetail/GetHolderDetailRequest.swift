import Foundation
public class GetHolderDetailRequest: BSANSoapRequest <GetHolderDetailRequestParams, GetHolderDetailHandler, GetHolderDetailResponse, GetHolderDetailParser> {
    
    public static let serviceName = "obtenerDetalleTitular_LA"
    private static let customFacade = "ACMOSPCAConsultaPlanes";
    
    public override var serviceName: String {
        return GetHolderDetailRequest.serviceName
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
            "      <n3:\(serviceName) xmlns:n3=\"\(nameSpace)\(GetHolderDetailRequest.customFacade)/v1\" facade=\"\(GetHolderDetailRequest.customFacade)\">" +
            "           <datosCabecera>" +
            "               <version>\(params.version)</version>" +
            "               <terminalID>\(params.terminalId)</terminalID>" +
            "               <idioma>" +
            "                   <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                   <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "               </idioma>" +
            "           </datosCabecera>" +
            "           <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            "           <entrada>" +
            "               <contrato>" +
            "                   <CENTRO>" +
            "                       <EMPRESA>\(empresa)</EMPRESA>" +
            "                       <CENTRO>\(centro)</CENTRO>" +
            "                   </CENTRO>" +
            "                   <PRODUCTO>\(producto)</PRODUCTO>" +
            "                   <NUMERO_DE_CONTRATO>\(numeroContrato)</NUMERO_DE_CONTRATO>" +
            "               </contrato>" +
            "               <claveBuscada>\(params.portfolioId)</claveBuscada>" +
            "               <indTipoCartera>\(params.portfolioTypeInd)</indTipoCartera>" +
            "               <idCartera>\(params.portfolioId)</idCartera>" +
            "           </entrada>" +
            "      </n3:\(serviceName)>" +
            "   </v:Body>" +
        "</v:Envelope>";
        
        return returnString
    }
}