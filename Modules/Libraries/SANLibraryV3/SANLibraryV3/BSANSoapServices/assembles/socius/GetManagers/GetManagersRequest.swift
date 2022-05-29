import Foundation
public class GetManagersRequest: BSANSoapRequest <GetManagersRequestParams, GetManagersHandler, GetManagersResponse, GetManagersParser> {
    
    public static let serviceName = "getGestoresCliente"
    
    public override var serviceName: String {
        return GetManagersRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://pc.adn.isb.com/"
    }
    
    override var message: String {
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1.0\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName)>" +
            "          <empresa>\(params.userDataDTO.contract?.bankCode ?? "")</empresa>" +
            "          <tipoPer>\(params.userDataDTO.clientPersonType ?? "")</tipoPer>" +
            "          <codPer>\(params.userDataDTO.clientPersonCode ?? "")</codPer>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
