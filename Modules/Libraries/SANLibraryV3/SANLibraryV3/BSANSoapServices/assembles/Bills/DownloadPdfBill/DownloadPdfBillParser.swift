import Foundation
import Fuzi

public class DownloadPdfBillParser: BSANParser<DownloadPdfBillResponse, DownloadPdfBillHandler> {
        
    override func setResponseData() {        
        response.documentDTO = handler.documentDTO
    }
}

public class DownloadPdfBillHandler: BSANHandler {
    
    var documentDTO = DocumentDTO()
    
    override func parseResult(result: XMLElement) throws {
        documentDTO.document = try parseDocument(fromElement: result)
    }
    
    func parseDocument(fromElement element: XMLElement) throws -> String? {
        guard let document = element.firstChild(tag: "pdf") else {
            return nil
        }
        return document.stringValue.trim().replace("\n", "")
    }
}
extension DownloadPdfBillHandler: PdfDocumentNodeHandler {}

