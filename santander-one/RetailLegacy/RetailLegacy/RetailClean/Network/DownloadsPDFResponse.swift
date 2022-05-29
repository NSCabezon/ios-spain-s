import Foundation

struct DownloadsPDFResponse {
    let data: PDFDocumentDTO
}

extension DownloadsPDFResponse: NetworkResponse {
    init(response: Data) {
        self.data = PDFDocumentDTO(data: response)
    }
}
