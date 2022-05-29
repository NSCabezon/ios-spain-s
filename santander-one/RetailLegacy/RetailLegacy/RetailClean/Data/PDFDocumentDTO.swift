import Foundation

struct PDFDocumentDTO {
    
    let data: Data
    let url: URL?
    
    init(data: Data, url: URL? = nil) {
        self.data = data
        self.url = url
    }
}
