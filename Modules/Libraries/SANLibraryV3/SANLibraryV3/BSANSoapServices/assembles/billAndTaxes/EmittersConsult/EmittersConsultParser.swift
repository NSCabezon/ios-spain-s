import Foundation
import Fuzi

public class EmittersConsultParser: BSANParser<EmittersConsultResponse, EmittersConsultHandler> {
        
    override func setResponseData() {
        response.emittersConsult = EmittersConsultDTO(
            emitterList: handler.emitterList,
            pagination: handler.pagination
        )
    }
}

public class EmittersConsultHandler: BSANHandler {
    var emitterList: [EmitterDTO] = []
    var pagination: PaginationDTO?
    
    override func parseResult(result: XMLElement) throws {
        let emitterElements = result.firstChild(tag: "lista")
        try emitterElements?.children.forEach(parseElement)
        let paginationElement = result.firstChild(tag: "paginacion")
        self.pagination = try EmitterPaginationParser.parse(paginationElement)
    }
    
    override func parseElement(element: XMLElement) throws {
        guard let emitter = try EmitterParser.parse(element) else { return }
        self.emitterList.append(emitter)
    }
}

final class EmitterParser {
    static func parse(_ element: XMLElement) throws -> EmitterDTO? {
        guard let name = element.firstChild(tag: "nombre")?.stringValue,
              let code = element.firstChild(tag: "codigo")?.stringValue
        else { return nil }
        
        return EmitterDTO(name: name, code: code)
    }
}

final class EmitterPaginationParser {
    static func parse(_ element: XMLElement?) throws -> PaginationDTO? {
        guard let element = element else { return nil }
        let indicadorPaginacion = element.firstChild(tag: "indicadorPaginacion")?.stringValue ?? "s"
        let endList = indicadorPaginacion.lowercased() == "s" ? true : false
        return PaginationDTO(repositionXML: element.description, accountAmountXML: "", endList: endList)
    }
}
