import Fuzi

public class SepaPayeeDetailHandler: BSANHandler {
    
    var sepaPayeeDetailDTO: SepaPayeeDetailDTO?
    
    override func parseResult(result: XMLElement) throws {
        sepaPayeeDetailDTO = try SepaPayeeDetailParser.parse(from: result)
    }
    
}

public class SepaPayeeDetailParser: BSANParser<SepaPayeeDetailResponse, SepaPayeeDetailHandler> {
    
    override func setResponseData() {
        response.sepaPayeeDetailDTO = handler.sepaPayeeDetailDTO
    }
    
    static func parse(from element: XMLElement) throws -> SepaPayeeDetailDTO? {
        guard let payeeCode = element.firstChild(tag: "codPayee")?.stringValue.trim() else {
            return nil
        }
        return SepaPayeeDetailDTO (payeeCode: payeeCode)
    }
    
}
