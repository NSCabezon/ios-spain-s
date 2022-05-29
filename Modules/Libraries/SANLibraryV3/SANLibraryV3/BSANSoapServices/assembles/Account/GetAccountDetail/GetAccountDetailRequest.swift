import Foundation

public class GetAccountDetailRequest: BSANSoapRequest <GetAccountDetailRequestParams, GetAccountDetailHandler, GetAccountDetailResponse, GetAccountDetailParser> {
    
    public static let serviceName = "detalleCuenta_LIP"
    
    public override var serviceName: String {
        return GetAccountDetailRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Cuentas/F_bamobi_cuentas_lip/internet/"
    }
    
    override var message: String {
        let empresa = params.bankCode
        let centro = params.branchCode
        let producto = params.product
        let numeroContrato = params.contractNumber
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "           <entrada>" +
            "               <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            "               <contratoID>" +
            "                    <CENTRO>" +
            "                        <EMPRESA>\(empresa)</EMPRESA>" +
            "                        <CENTRO>\(centro)</CENTRO>" +
            "                    </CENTRO>" +
            "                    <PRODUCTO>\(producto)</PRODUCTO>" +
            "                    <NUMERO_DE_CONTRATO>\(numeroContrato)</NUMERO_DE_CONTRATO>" +
            "               </contratoID>" +
            "           </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}

