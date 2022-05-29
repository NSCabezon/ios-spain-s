import Foundation
import Fuzi

public class BillCollectionListParser: BSANParser<BillCollectionListResponse, BillCollectionListHandler> {
        
    override func setResponseData() {
        response.billCollectionList = BillCollectionListDTO(billCollections: handler.billCollections, pagination: handler.pagination)
    }
}

public class BillCollectionListHandler: BSANHandler {
    
    fileprivate var billCollections: [BillCollectionDTO] = []
    fileprivate var pagination: PaginationDTO?
    
    override func parseResult(result: XMLElement) throws {
        let billCollectionsElement = result.firstChild(tag: "lista")
        let paginationElement = result.firstChild(tag: "paginacion")
        self.pagination = BilCollettionlListPaginationParser.parse(from: paginationElement)
        try billCollectionsElement?.children.forEach(parseElement)
    }
    
    override func parseElement(element: XMLElement) throws {
        guard let billCollection = try BillCollectionParser.parse(from: element) else {
            return
        }
        billCollections.append(billCollection)
    }
}

class BillCollectionParser {
    
    static func parse(from element: XMLElement) throws -> BillCollectionDTO? {
        guard
            let productIdentifier = element.firstChild(tag: "IdentificadorProducto")?.stringValue,
            let typeCode = element.firstChild(tag: "CodigoTipoRecaudacion")?.stringValue,
            let code = element.firstChild(tag: "CodigoRecaudacion")?.stringValue,
            let description = element.firstChild(tag: "DescripcionRecaudacion")?.stringValue.trim(),
            let operationTypeCode = element.firstChild(tag: "CodigoTipoOperacion")?.stringValue,
            let indicatorModifiesAmount = element.firstChild(tag: "IndicadorModificaImporte")?.stringValue,
            let indicatorModifiesCurrency = element.firstChild(tag: "ImdicadorModificaMoneda")?.stringValue
        else {
            return nil
        }
        return BillCollectionDTO(
            productIdentifier: productIdentifier,
            typeCode: typeCode,
            code: code,
            description: description,
            operationTypeCode: operationTypeCode,
            indicatorModifiesAmount: indicatorModifiesAmount,
            indicatorModifiesCurrency: indicatorModifiesCurrency
        )
    }
}

class BilCollettionlListPaginationParser {
    static func parse(from element: XMLElement?) -> PaginationDTO? {
        guard let element = element else { return nil }
        let indicadorPaginacion = element.firstChild(tag: "indicadorPaginacion")?.stringValue ?? "s"
        let endList = indicadorPaginacion.lowercased() == "s" ? true : false
        return PaginationDTO(repositionXML: element.description, accountAmountXML: "", endList: endList)
    }
}

