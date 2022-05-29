import CoreFoundationLib
import Foundation

class DocumentsRepositoryImp: DocumentsRepository {
    
    private let persistanceDataSource: DownloadsPersistanceDataSource
    
    init(persistanceDataSource: DownloadsPersistanceDataSource) {
        self.persistanceDataSource = persistanceDataSource
    }
}

extension DocumentsRepositoryImp {
    
    func save(fileName: String, data: Data) throws -> RepositoryResponse<URL> {
        persistanceDataSource.setPDF(url: fileName, document: PDFDocumentDTO(data: data))
        guard let pdf = persistanceDataSource.getPDF(url: fileName), let url = pdf.url else {
            throw DocumentsRepositoryError.errorSavingData
        }
        return LocalResponse(url)
    }
}
