import Foundation

public class GetFundTransactionsRequest: BSANSoapRequest <GetFundTransactionsRequestParams, GetFundTransactionsHandler, GetFundTransactionsResponse, GetFundTransactionsParser> {

	public static let serviceName = "listaMovimientosFondo_LA"
	public static let serviceNamePagination = "listaMovimientosFondoRepos_LA"

    public override var serviceName: String {
		if params.pagination == nil {
			return GetFundTransactionsRequest.serviceName
		} else {
			return GetFundTransactionsRequest.serviceNamePagination
		}
    }
    
    override var nameSpace: String {
		return "http://www.isban.es/webservices/BAMOBI/Fondos/F_bamobi_fondos_lip/internet/"
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
			"          <entrada>" +
			"             <contrato>" +
			"                <CENTRO>" +
			"                   <EMPRESA>\(bankCode)</EMPRESA>" +
			"                   <CENTRO>\(branchCode)</CENTRO>" +
			"                </CENTRO>" +
			"                <PRODUCTO>\(product)</PRODUCTO>" +
			"                <NUMERO_DE_CONTRATO>\(contractNumber)</NUMERO_DE_CONTRATO>" +
			"             </contrato>" +
							getDateFilterMessage() +
			"             <divisa>\(params.currencyType?.name ?? "")</divisa>" +
			"          </entrada>" +
			"           \(params.pagination?.repositionXML ?? "")" +
			"          <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
			"          <datosCabecera>" +
			"             <version>\(params.version)</version>" +
			"             <terminalID>\(params.terminalId)</terminalID>" +
			"             <idioma>\(serviceLanguage(params.language))</idioma>" +
			"          </datosCabecera>" +
			"       </v1:\(serviceName)>" +
			"    </soapenv:Body>" +
		"</soapenv:Envelope>"
		return returnString
	}
}
