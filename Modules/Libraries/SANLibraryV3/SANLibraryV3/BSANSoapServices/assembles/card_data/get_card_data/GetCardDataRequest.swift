import Foundation

public class GetCardDataRequest: BSANSoapRequest<GetCardDataRequestParams, GetCardDataHandler, GetCardDataResponse, GetCardDataParser> {

    public static let SERVICE_NAME = "consWalletTarjetasCliente_LA"

    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Consultaimagen_la/F_tarsan_consultaimagen_la/internet/"
    }

    public override var serviceName: String {
        return GetCardDataRequest.SERVICE_NAME
    }
    
    override var message: String {
        
        let empresa = params.reposDatosTarjeta?.contratoTarjeta?.bankCode ?? ""
        let centro = params.reposDatosTarjeta?.contratoTarjeta?.branchCode ?? ""
        let producto = params.reposDatosTarjeta?.contratoTarjeta?.product ?? ""
        let numeroContrato = params.reposDatosTarjeta?.contratoTarjeta?.contractNumber ?? ""
        let codigoAplicacion = params.reposDatosTarjeta?.codigoAplicacion ?? ""
        let tipoIntervencion = params.reposDatosTarjeta?.tipoIntervencion ?? ""
        let numBeneficiario = params.reposDatosTarjeta?.numBeneficiario ?? ""
        let numBenefTarjeta = params.reposDatosTarjeta?.numBenefTarjeta ?? ""
        let finLista = params.reposDatosTarjeta?.finLista == true ? "S" : "N"
        
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
            + "         xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "        <soapenv:Header>"
            + "                \(getSecurityHeader(params.token))"
            + "                </soapenv:Header>"
            + "        <soapenv:Body>"
            + "        <v1:\(serviceName) facade=\"\(facade)\">"
            + "        <entrada>"
            + "                <indicadorRepo>\(params.indicadorRepo ?? "")</indicadorRepo>"
            + "            </entrada>"
            + "        <datosCabecera>"
            + "                <idioma>\(serviceLanguage(params.language ?? ""))</idioma>"
            + "                <empresaAsociada>\(params.linkedCompany ?? "")</empresaAsociada>"
            + "        </datosCabecera>"
            + "        <datosConexion>"
            + "                \(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")"
            + "        </datosConexion>"
            + "        <repos>"
            + "                <contratoTarjeta>"
            + "                    <CENTRO>"
            + "                        <EMPRESA>\(empresa)</EMPRESA>"
            + "                        <CENTRO>\(centro)</CENTRO>"
            + "                    </CENTRO>"
            + "                    <PRODUCTO>\(producto)</PRODUCTO>"
            + "                    <NUMERO_DE_CONTRATO>\(numeroContrato)</NUMERO_DE_CONTRATO>"
            + "                </contratoTarjeta>"
            + "                <codigoAplicacion>\(codigoAplicacion)</codigoAplicacion>"
            + "                <tipoIntervencion>\(tipoIntervencion)</tipoIntervencion>"
            + "                <numBeneficiario>\(numBeneficiario)</numBeneficiario>"
            + "                <numBenefTarjeta>\(numBenefTarjeta)</numBenefTarjeta>"
            + "                <finLista>\(finLista)</finLista>"
            + "           </repos>"
            + "        </v1:\(serviceName)>"
            + "        </soapenv:Body>"
            + "        </soapenv:Envelope>"
    }

}


public class GetCardDataRequestParams {
    
    public static func createParams(_ token: String) -> GetCardDataRequestParams {
        return GetCardDataRequestParams(token)
    }
    
    var token: String
    var linkedCompany:String?
    var userDataDTO: UserDataDTO?
    var language:String?
    var reposDatosTarjeta:ReposDatosTarjeta?
    var indicadorRepo:String?
    
    private init(_ token: String) {
        self.token = token
    }
    
    public func setUserDataDTO(_ userDataDTO: UserDataDTO) -> GetCardDataRequestParams{
        self.userDataDTO = userDataDTO
        return self;
    }
    
    public func setReposDatosTarjeta(_ reposDatosTarjeta: ReposDatosTarjeta?) -> GetCardDataRequestParams{
        self.reposDatosTarjeta = reposDatosTarjeta
        return self;
    }
    
    public func setLinkedCompany(_ linkedCompany: String) -> GetCardDataRequestParams{
        self.linkedCompany = linkedCompany
        return self
    }
    
    
    public func setLanguage(_ language: String) -> GetCardDataRequestParams {
        self.language = language
        return self
    }
    
    public func setIndicadorRepo(_ indicadorRepo: String) -> GetCardDataRequestParams {
        self.indicadorRepo = indicadorRepo
        return self
    }
    
}
