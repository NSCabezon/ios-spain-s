import Foundation

import Fuzi

public class CheckExtractPdfParser : BSANParser <CheckExtractPdfResponse, CheckExtractPdfHandler> {
    override func setResponseData(){
        response.documentDTO = handler.documentDTO
    }
}

public class CheckExtractPdfHandler: BSANHandler {
    
    var documentDTO = DocumentDTO()
    
    override func parseResult(result: XMLElement) throws {
        documentDTO.document = try parseDocument(fromElement: result)
    }
}

extension CheckExtractPdfHandler: PdfDocumentNodeHandler {}

protocol PdfDocumentNodeHandler {
    func parseDocument(fromElement element: XMLElement) throws -> String?
}

extension PdfDocumentNodeHandler where Self: BSANHandler {
    func parseDocument(fromElement element: XMLElement) throws -> String? {
        guard let document = element.firstChild(tag: "documento") else {
            return nil
        }
        return document.stringValue.trim().replace("\n", "")
    }
}
