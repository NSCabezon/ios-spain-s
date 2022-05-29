protocol DownloadsPersistanceDataSource {
    func setPDF(url: String, document: PDFDocumentDTO)
    func getPDF(url: String) -> PDFDocumentDTO?
    func removeCache()
}

class DownloadsPersistanceDataSourceImpl {
    private let pdfCache: AppDocumentsCache
    
    init(pdfCache: AppDocumentsCache) {
        self.pdfCache = pdfCache
    }
}

extension DownloadsPersistanceDataSourceImpl: DownloadsPersistanceDataSource {
    func setPDF(url: String, document: PDFDocumentDTO) {
        pdfCache.persist(document: document.data, withFileName: url)
    }
    
    func getPDF(url: String) -> PDFDocumentDTO? {
        if let document = pdfCache.obtainDocument(withFileName: url) {
            return PDFDocumentDTO(data: document.data, url: document.url)
        }
        return nil
    }
    
    func removeCache() {
        pdfCache.remove()
    }
}
