import Foundation

public class RecoverPrepaidCardDataRequest: BSANSoapRequest<RecoverPrepaidCardDataRequestParams, RecoverPrepaidCardDataHandler, RecoverPrepaidCardDataResponse, RecoverPrepaidCardDataParser> {

    public static let SERVICE_NAME = "recuperarDatosTarjetaPrePago_LA";

    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Recargaecash_la/F_tarsan_recargaecash_la/internet/"
    }

    public override var serviceName: String {
        return RecoverPrepaidCardDataRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "    xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>" +
            "     \(getSecurityHeader(params.token))" +
            "    </soapenv:Header>" +
            "    <soapenv:Body>" +
            "        <v1:\(serviceName) facade=\"\(facade)\">" +
            "            <entrada>" +
            "                <contratoTarjeta>" +
            "                    <CENTRO>" +
            "                        <EMPRESA>\(params.cardDTO?.contract?.bankCode ?? "")</EMPRESA>" +
            "                        <CENTRO>\(params.cardDTO?.contract?.branchCode ?? "")</CENTRO>" +
            "                    </CENTRO>" +
            "                    <PRODUCTO>\(params.cardDTO?.contract?.product ?? "")</PRODUCTO>" +
            "                    <NUMERO_DE_CONTRATO>\(params.cardDTO?.contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
            "                </contratoTarjeta>" +
            "                <numTarjeta>\(params.cardDTO!.PAN!)</numTarjeta>" +
            "            </entrada>" +
            "            <datosConexion>" +
            "            \(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")" +
            "            </datosConexion>" +
            "            <datosCabecera>" +
            "                <idioma>" +
            "                    <IDIOMA_ISO>\(serviceLanguage(params.languageISO ?? ""))</IDIOMA_ISO>" +
            "                    <DIALECTO_ISO>\(params.dialectISO ?? "")</DIALECTO_ISO>" +
            "                </idioma>" +
            "                <empresaAsociada>\(params.linkedCompany ?? "")</empresaAsociada>" +
            "            </datosCabecera>" +
            "        </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
    
}


public class RecoverPrepaidCardDataRequestParams {
    
    public static func createParams(_ token: String) -> RecoverPrepaidCardDataRequestParams {
        return RecoverPrepaidCardDataRequestParams(token)
    }
    
    var token: String
    var userDataDTO: UserDataDTO?
    var languageISO: String?
    var dialectISO: String?
    var linkedCompany: String?
    var cardDTO: CardDTO?
    
    private init(_ token: String) {
        self.token = token
    }
    
    public func setUserDataDTO(_ userDataDTO: UserDataDTO) -> RecoverPrepaidCardDataRequestParams {
        self.userDataDTO = userDataDTO
        return self
    }
    
    public func setLanguageISO(_ languageISO: String) -> RecoverPrepaidCardDataRequestParams {
        self.languageISO = languageISO
        return self
    }
    
    public func setDialectISO(_ dialectISO: String) -> RecoverPrepaidCardDataRequestParams {
        self.dialectISO = dialectISO
        return self
    }
    
    public func setLinkedCompany(_ linkedCompany: String) -> RecoverPrepaidCardDataRequestParams {
        self.linkedCompany = linkedCompany
        return self
    }
    
    public func setCardDTO(_ cardDTO: CardDTO) -> RecoverPrepaidCardDataRequestParams {
        self.cardDTO = cardDTO
        return self
    }

    

}
