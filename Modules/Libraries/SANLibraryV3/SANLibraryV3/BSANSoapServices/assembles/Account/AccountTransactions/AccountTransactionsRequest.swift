import Foundation

public class AccountTransactionsRequest: BSANSoapRequest <AccountTransactionsRequestParams, AccountTransactionsHandler, AccountTransactionsResponse, AccountTransactionsParser> {

	public static let serviceName = "listaMovCuentas_LIP"
	public static let serviceNameDates = "listaMovCuentasFechas_LIP"

    public override var serviceName: String {
		if params.dateFilter == nil {
			return AccountTransactionsRequest.serviceName
		} else {
			return AccountTransactionsRequest.serviceNameDates
		}
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Cuentas/F_bamobi_cuentas_lip/internet/"
	}
	
	override var message: String {
		let empresa = params.bankCode
		let centro = params.branchCode
		let producto = params.product
		let numeroContrato = params.contractNumber
		let isPagination = params.pagination != nil ? "S" : "N"
		let pagination = params.pagination?.repositionXML
		let paginationAmount = params.pagination?.accountAmountXML
		
		let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
			" xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
			"   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
			"       <soapenv:Body>" +
			"           <v1:" + serviceName + " facade=\"" + facade + "\">" +
			"           <entrada>" +
			"               <datosCabecera>" +
			"                   <version>\(params.version)</version>" +
			"                   <terminalID>\(params.terminalId)</terminalID>" +
			"                   <idioma>\(serviceLanguage(params.language))</idioma>" +
			"               </datosCabecera>" +
			"               <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
			"               <contratoID>" +
			"                    <CENTRO>" +
			"                        <EMPRESA>\(empresa)</EMPRESA>" +
			"                        <CENTRO>\(centro)</CENTRO>" +
			"                    </CENTRO>" +
			"                    <PRODUCTO>\(producto)</PRODUCTO>" +
			"                    <NUMERO_DE_CONTRATO>\(numeroContrato)</NUMERO_DE_CONTRATO>" +
			"               </contratoID>" +
			getDateFilterMessage() +
			"               \(paginationAmount ?? "")" +
			"               <esUnaPaginacion>\(isPagination)</esUnaPaginacion>" +
			"               \(pagination ?? "")" +
			"           </entrada>" +
			"       </v1:\(serviceName)>" +
			"   </soapenv:Body>" +
		"</soapenv:Envelope>"
		return returnString
	}
}
