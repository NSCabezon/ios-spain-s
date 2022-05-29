//

import Foundation

public class AccountEasyPayRequest: BSANSoapRequest<AccountEasyPayRequestParams, AccountEasyPayHandler, AccountEasyPayResponse, AccountEasyPayParser> {
    
    static public var serviceName = "obtenerCampaCliente_LA"
    
    public override var serviceName: String {
        return AccountEasyPayRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/OFECOM/Ofertascomerciales_la/F_ofecom_ofertascomerciales_la/internet/ACOFECOM/v1"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                    <entrada>
                        <empresa>\(params.userDataDTO.company ?? "")</empresa>
                        <canal>002</canal>
                        <listaFamilias>
                            <familia>T05</familia>
                        </listaFamilias>
                    </entrada>
                    <datosConexion>
                        \(params.userDataDTO.datosUsuario)
                    </datosConexion>
                    <datosCabecera>
                        <idioma>
                            <IDIOMA_ISO>\(serviceLanguage(params.language))</IDIOMA_ISO>
                            <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
                        </idioma>
                    </datosCabecera>
                    <paginacion>
                        <campania>
                            <EMPRESA></EMPRESA>
                            <COD_ALFANUM_6></COD_ALFANUM_6>
                        </campania>
                        <codFamilia></codFamilia>
                        <indPaginacion></indPaginacion>
                    </paginacion>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
