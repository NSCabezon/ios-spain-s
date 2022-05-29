import Foundation

public class GetSociusDetailAccountsAllRequest: BSANSoapRequest<GetSociusDetailAccountsAllRequestParams, GetSociusDetailAccountsAllHandler, GetSociusDetailAccountsAllResponse, GetSociusDetailAccountsAllParser> {

    public static let SERVICE_NAME = "getDetalleCuentasSociusAll"

    override var nameSpace: String {
        return "http://pc.adn.isb.com/"
    }

    public override var serviceName: String {
        return GetSociusDetailAccountsAllRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1.0\">" +
            "  <soapenv:Header>" +
            "    \(getSecurityHeader(params.token))" +
            "  </soapenv:Header>" +
            "  <soapenv:Body>" +
            "    <v1:\(serviceName)>" +
            "      <empresa>\(params.userDataDTO?.contract?.bankCode ?? "")</empresa>" +
            "      <tipoPer>\(params.userDataDTO?.clientPersonType ?? "")</tipoPer>" +
            "      <codPer>\(params.userDataDTO?.clientPersonCode ?? "")</codPer>" +
            "    </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
        "</soapenv:Envelope> "
    }
    
}


public class GetSociusDetailAccountsAllRequestParams {
    
    public static func createParams(_ token: String) -> GetSociusDetailAccountsAllRequestParams {
        return GetSociusDetailAccountsAllRequestParams(token)
    }
    
    var token: String
    var userDataDTO: UserDataDTO?
    
    private init(_ token: String) {
        self.token = token
    }
    
    public func setUserDataDTO(_ userDataDTO: UserDataDTO) -> GetSociusDetailAccountsAllRequestParams {
        self.userDataDTO = userDataDTO
        return self
    }    
    
}
