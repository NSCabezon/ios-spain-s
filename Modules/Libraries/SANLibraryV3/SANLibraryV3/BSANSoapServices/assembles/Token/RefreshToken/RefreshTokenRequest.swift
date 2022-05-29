import Foundation

public class RefreshTokenRequest: BSANSoapRequest <RefreshTokenRequestParams, RefreshTokenHandler, RefreshTokenResponse, RefreshTokenParser> {

	public static let SERVICE_NAME = "getLoggedUserToken"

    public override var serviceName: String {
        return RefreshTokenRequest.SERVICE_NAME
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TECHNICAL_FACADES/Security/F_facseg_security/internet/"
	}
	
	override var message: String {
		let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
			"    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
			"    <soapenv:Body>" +
			"        <v1:getLoggedUserToken facade=\"\(facade)\"/>" +
			"    </soapenv:Body>" +
		"</soapenv:Envelope>";
		return returnString
	}
}
