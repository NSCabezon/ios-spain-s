import Foundation

import Fuzi

public class CheckMovementPdfParser : BSANParser <CheckMovementPdfResponse, CheckMovementPdfHandler> {
    override func setResponseData(){
        response.documentDTO = handler.documentDTO
    }
}

public class CheckMovementPdfHandler: BSANHandler {
    
    var documentDTO = DocumentDTO()
    
    override func parseResult(result: XMLElement) throws {
        documentDTO.document = try parseDocument(fromElement: result)
    }
}

extension CheckMovementPdfHandler: PdfDocumentNodeHandler {}

