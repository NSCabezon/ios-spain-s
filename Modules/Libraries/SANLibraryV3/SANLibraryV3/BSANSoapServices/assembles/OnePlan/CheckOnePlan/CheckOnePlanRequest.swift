//

import Foundation

public class CheckOnePlanRequest: BSANSoapRequest<CheckOnePlanRequestParams, CheckOnePlanHandler, CheckOnePlanResponse, CheckOnePlanParser> {
    
    public static let SERVICE_NAME = "tenenciasDePlanes_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/ADFIEL/Gestioncmc_la/F_adfiel_gestioncmc_la/WSTENENCIAPLANES/v1"
    }
    
    public override var serviceName: String {
        return CheckOnePlanRequest.SERVICE_NAME
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
        \(header)
        \(messageBody)
        </soapenv:Envelope>
        """
    }
    
    var header: String {
        return """
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
        """
    }
    
    var messageBody: String {
        return """
        <soapenv:Body>
            <v1:\(serviceName) facade="\(facade)">
                <conexion>
                    \(language)
                    \(linkedCompany)
                    \(branchCode)
                </conexion>
                <entrada>
                    <listaProductos>
                        \(productList)
                    </listaProductos>
                </entrada>
            </v1:\(serviceName)>
        </soapenv:Body>
        """
    }
    
    var language: String {
        return """
        <idioma>
           <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>
           <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>
        </idioma>
        """
    }
    
    var linkedCompany: String {
        return """
        <empresa>\(params.linkedCompany)</empresa>
        """
    }
    
    var branchCode: String {
        guard let branchCode = params.userDataDTO.channelFrame else { return "" }
        return """
        <canal>\(branchCode)</canal>
        """
    }
    
    var productList: String {
        var productList = ""
        for range in params.productRanges {
            for subtype in range.subtypeFrom...range.subtypeTo {
                productList += """
                <producto>
                    <codigoProducto>\(String(format: "%03d", range.type))</codigoProducto>
                    <subtipoProducto>\(String(format: "%03d", subtype))</subtipoProducto>
                </producto>
                """
            }
        }
        return productList
    }
}

public struct CheckOnePlanRequestParams {
    public let token: String
    public let languageISO: String
    public let dialectISO: String
    public let linkedCompany: String
    public let userDataDTO: UserDataDTO
    public let productRanges: [ProductOneRangeDTO]
}
