import Foundation

public class GetEmittedTransferDetailRequest: BSANSoapRequest<GetEmittedTransferDetailRequestParams, GetEmittedTransferDetailHandler, GetEmittedTransferDetailResponse, GetEmittedTransferDetailParser> {

    private static let SERVICE_NAME = "detalleEmitidaSepaIntLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Transfcobrossepa_la/F_bamobi_transfcobrossepa_la/internet/"
    }
    
    public override var serviceName: String {
        return GetEmittedTransferDetailRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "   <soapenv:Body>" +
            "      <v1:\(serviceName) facade=\"\(facade)\">" +
            "       <datosConexion>" +
            "            <idioma>" +
            "               <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "               <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "            </idioma>" +
            "            \(params.userDataDTO.getUserDataWithChannelAndCompany)" +
            "         </datosConexion>" +
            "       <entrada>" +
            "           <ordenServicio>" +
            "              <CENTRO>" +
            "                 <EMPRESA>\(params.bankCode)</EMPRESA>" +
            "                 <CENTRO>\(params.branchCode)</CENTRO>" +
            "              </CENTRO>" +
            "              <PRODUCTO>\(params.product)</PRODUCTO>" +
            "              <NUMERO_DE_ORDEN>\(params.contractNumber)</NUMERO_DE_ORDEN>" +
            "            </ordenServicio>" +
            "            <numeroTransferencia>\(params.transferNumber)</numeroTransferencia>" +
            "            <codigoAplicacion>\(params.appCode)</codigoAplicacion>" +
            "         </entrada>" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
            "</soapenv:Envelope>"
    }
}

public struct GetEmittedTransferDetailRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let bankCode: String
    public let branchCode: String
    public let product: String
    public let contractNumber: String
    public let transferNumber: String
    public let appCode: String
}

