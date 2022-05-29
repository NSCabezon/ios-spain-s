import CoreDomain
import Foundation

public class BSANSoapRequest<Params, Handler, Response, Parser> where Parser: BSANParser<Response, Handler> {
    
    public var serviceName: String {
        fatalError()
    }

    public var serviceUrl: String {
        return baseServiceUrl + relativeServiceUrl
    }
    public var body: String {
        return createMessage()
    }

    var nameSpace: String {
        fatalError()
    }
    var message: String {
        fatalError()
    }

    var params: Params

    var LOG_TAG: String {
        return String(describing: type(of: self))
    }

    var bsanAssemble: BSANAssemble
    var urlBase: String

    public init(_ bsanAssemble: BSANAssemble, _ urlBase: String, _ params: Params) {
        self.bsanAssemble = bsanAssemble
        self.urlBase = urlBase
        self.params = params
    }

    var baseServiceUrl: String {
        return urlBase
    }

    var relativeServiceUrl: String {
        return bsanAssemble.endPoint
    }

    var acronym: String? {
        return bsanAssemble.acronym
    }

    var facade: String {
        return bsanAssemble.facade
    }

    var parser: Parser {
        return Parser.init()
    }

    func getResponse(response: String) -> Response {
        return Response.init(response: response)
    }

    func getSecurityHeader(_ token: String) -> String {
        return "<wsse:Security SOAP-ENV:actor=\"http://www.isban.es/soap/actor/wssecurityB64\" SOAP-ENV:mustUnderstand=\"1\" S12:role=\"wsssecurity\" xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:S12=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                        + "    <wsse:BinarySecurityToken xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" wsu:Id=\"SSOToken\" ValueType=\"esquema\" EncodingType=\"hwsse:Base64Binary\">\(token)</wsse:BinarySecurityToken>\n"
                        + "</wsse:Security>"
    }

    func getSignatureXml(signatureDTO: SignatureDTO) -> String {
        var xml = ""
        if let positions = signatureDTO.positions, positions.count > 0,
           let values = signatureDTO.values, values.count > 0 {
            for i in 0...positions.count - 1 {
                xml += "<c\(positions[i])>\(values[i])</c\(positions[i])>"
            }
        }
        return xml
    }

    func getSignatureXmlFormatP(signatureDTO: SignatureDTO) -> String {
        var xml = ""
        if let positions = signatureDTO.positions, positions.count > 0,
           let values = signatureDTO.values, values.count > 0 {
            for i in 0...positions.count - 1 {
                xml += "<p\(positions[i])>\(values[i])</p\(positions[i])>"
            }
        }
        return xml
    }

    func getDateXml(tagDate: String, date: Date?) -> String {

        if let date = date {
            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let year = calendar.component(Calendar.Component.year, from: date)
            let month = calendar.component(Calendar.Component.month, from: date)
            let day = calendar.component(Calendar.Component.day, from: date)

            return "<\(tagDate)><anyo>\(year)</anyo><mes>\(month < 10 ? "0" : "")\(month)</mes><dia>\(day < 10 ? "0" : "")\(day)</dia></\(tagDate)>"
        }

        return ""
    }
    
    func getTrusteerData(_ info: TrusteerInfoDTO?, withUrl url: String) -> String {
        guard let info = info else { return "" }
        return """
        <datosTrusteer>
            <remoteAddr>\(!info.disabledServicesIP.contains(serviceName) ? info.remoteAddr: "")</remoteAddr>
            <userAgent>\(info.userAgent)</userAgent>
            <customerSessionId>\(info.customerSessionId)</customerSessionId>
            <url>\(url)</url>
        </datosTrusteer>
        """
    }

    func parse(response: String) throws -> Response {

        BSANLogger.i(LOG_TAG, "parse")
        BSANLogger.d(LOG_TAG, "Response:\n\(response)")

        if !response.isEmpty {
            return try parser.parse(bsanResponse: getResponse(response: response))
        } else {
            throw BSANServiceException("Empty Response String!")
        }

    }

    func createMessage() -> String {
        BSANLogger.d(LOG_TAG, "Request:\n\(message)")
        return message
    }

    func formatXMLDesc(list: [PaymentBillTaxesItemDTO]) -> String {
        var result = ""
        for item in list {
            result += "<descFormato>\(item.formatDescription ?? "")</descFormato>\n"
        }
        return result
    }


}

extension BSANSoapRequest where Params: FiltrableRequest {
    func getDateFilterMessage() -> String {
        if let dateFilter = params.dateFilter {
            var date = ""
            if let fromDate = dateFilter.fromDateModel {
                date += "               <fechaDesde>" +
                        "                   <dia>\(fromDate.day)</dia>" +
                        "                   <mes>\(fromDate.month)</mes>" +
                        "                   <anyo>\(fromDate.year)</anyo>" +
                        "               </fechaDesde>"
            }

            if let toDate = dateFilter.toDateModel {
                date += "               <fechaHasta>" +
                        "                   <dia>\(toDate.day)</dia>" +
                        "                   <mes>\(toDate.month)</mes>" +
                        "                   <anyo>\(toDate.year)</anyo>" +
                        "               </fechaHasta>"
            }
            return date
        } else {
            return "";
        }
    }
}

extension BSANSoapRequest: SoapRequestDynamicLanguage {}

protocol FiltrableRequest {
    var dateFilter: DateFilter? { get }
}
