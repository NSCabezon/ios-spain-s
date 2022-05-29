import Foundation

public class TransferTypeRequest: BSANSoapRequest<TransferTypeRequestParams, TransferTypeHandler, TransferTypeResponse, TransferTypeParser> {
    
    private static let SERVICE_NAME = "tipoTransferencia_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Emisioninter_la/F_trasan_emisioninter_la/"
    }
    
    public override var serviceName: String {
        return TransferTypeRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "        <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "        <soapenv:Body>" +
            "           <v1:\(serviceName) facade=\"\(facade)\">" +
            "               <cabecera>" +
            "                   <idioma>" +
            "                       <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                       <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "                   </idioma>" +
            "                   <empresaAsociada>\(params.userDataDTO.company ?? "")</empresaAsociada>" +
            "               </cabecera>" +
            "               <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            "               <entrada>" +
            "                   <contratoOrdenante>" +
            "                       <CENTRO>" +
            "                           <EMPRESA>\(params.accountDTO.contract?.bankCode ?? "")</EMPRESA>" +
            "                           <CENTRO>\(params.accountDTO.contract?.branchCode ?? "")</CENTRO>" +
            "                       </CENTRO>" +
            "                       <PRODUCTO>\(params.accountDTO.contract?.product ?? "")</PRODUCTO>" +
            "                       <NUMERO_DE_CONTRATO>\(params.accountDTO.contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
            "                   </contratoOrdenante>" +
            "                   <paisSeleccionado>\(params.selectedCountry)</paisSeleccionado>" +
            "                   <monedaSeleccionada>\(params.selectedCurrency)</monedaSeleccionada>" +
            "               </entrada>" +
            "        </v1:\(serviceName)>" +
            "        </soapenv:Body>" +
        "        </soapenv:Envelope>"
    }
}

public struct TransferTypeRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let accountDTO: AccountDTO
    public let selectedCountry: String
    public let selectedCurrency: String
}
