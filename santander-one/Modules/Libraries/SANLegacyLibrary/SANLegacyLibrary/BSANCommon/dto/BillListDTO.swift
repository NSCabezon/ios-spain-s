import Fuzi

public struct BillListDTO: Codable {
    
    public let bills: [BillDTO]
    public let pagination: PaginationDTO?
    
    public init(bills: [BillDTO], pagination: PaginationDTO?) {
        self.bills = bills
        self.pagination = pagination
    }
}

/// This parser is necessary because the pagination needs some static data (SENTTRAS, TIPCA)
public class BillListPaginationParser {
    
    public static func parse(from element: XMLElement) -> PaginationDTO? {
        guard let paginationElement = element.firstChild(tag: "paginacion") else {
            return nil
        }
        var pagination = PaginationDTO()
        pagination.repositionXML = """
        <paginacion>
            \(paginationElement.firstChild(tag: "listaRecibosPaginacion")?.rawXML.trim() ?? "")
            \(paginationElement.firstChild(tag: "indicadorReposicionamiento")?.rawXML.trim() ?? "")
            \(paginationElement.firstChild(tag: "FECDES")?.rawXML.trim() ?? "")
            \(paginationElement.firstChild(tag: "FECHASD")?.rawXML.trim() ?? "")
            \(paginationElement.firstChild(tag: "IDCENTC")?.rawXML.trim() ?? "")
            \(paginationElement.firstChild(tag: "IDCENTR")?.rawXML.trim() ?? "")
            \(paginationElement.firstChild(tag: "LISTASI")?.rawXML.trim() ?? "")
            \(paginationElement.firstChild(tag: "NUMECONR")?.rawXML.trim() ?? "")
            \(paginationElement.firstChild(tag: "IDPRODR")?.rawXML.trim() ?? "")
            \(paginationElement.firstChild(tag: "ZIDCENT")?.rawXML.trim() ?? "")
            <SENTTRAS>R</SENTTRAS>
            <TIPCA>2</TIPCA>
        </paginacion>
        """.trim()
        pagination.endList = DTOParser.safeBoolean(element.firstChild(tag: "finLista")?.stringValue.trim())
        return pagination
    }
}
