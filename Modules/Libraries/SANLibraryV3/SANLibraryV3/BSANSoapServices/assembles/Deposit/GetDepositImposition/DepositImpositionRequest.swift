
import Foundation

public class DepositImpositionRequest: BSANSoapRequest <DepositImpositionsRequestParams, DepositImpositionHandler, DepositImpositionResponse, DepositImpositionParser> {

	public static let serviceName = "listaImposiciones_LA"
	public static let serviceNamePagination = "listaImposicionesRepos_LA"

    public override var serviceName: String {
		if params.pagination == nil {
			return DepositImpositionRequest.serviceName
		} else {
			return DepositImpositionRequest.serviceNamePagination
		}
    }
    
    override var nameSpace: String {
		return "http://www.isban.es/webservices/BAMOBI/Fondos/F_bamobi_fondos_lip/internet/"
	}
	
	override var message: String {
		let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
		
		let bankCode = params.bankCode
		let branchCode = params.branchCode
		let product = params.product
		let contractNumber = params.contractNumber
		
		let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
			"  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
			"    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
			"    <soapenv:Body>" +
			"       <v1:\(serviceName) facade=\"\(facade)\">" +
			"         <entrada>" +
			"            <contrato>" +
			"                   <CENTRO>" +
			"                       <CENTRO>\(branchCode)</CENTRO>" +   //EN EL SERVICIO ESTAN INVERTIDOS ESTOS DOS CAMPOS (EN COMPARACION CON OTROS SERVICIOS)
			"                       <EMPRESA>\(bankCode)</EMPRESA>" +
			"                   </CENTRO>" +
			"                   <PRODUCTO>\(product)</PRODUCTO>" +
			"                   <NUMERO_DE_CONTRATO>\(contractNumber)</NUMERO_DE_CONTRATO>" +
			"            </contrato>" +
			"         </entrada>" +
			"           \(params.pagination?.repositionXML ?? "")" +
			"               <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
			"               <datosCabecera>" +
			"                   <version>\(params.version)</version>" +
			"                   <terminalID>\(params.terminalId)</terminalID>" +
			"                   <idioma>\(serviceLanguage(params.language))</idioma>" +
			"               </datosCabecera>" +
			"      </v1:\(serviceName)>" +
			"   </soapenv:Body>" +
		"</soapenv:Envelope>";
		return returnString
	}
}
