import CoreFoundationLib
import Foundation

class DownloadsRepositoryImpl {
    private let appRepository: AppRepository
    private let networkService: NetworkService
    private let persistanceDataSource: DownloadsPersistanceDataSource
    
    init(appRepository: AppRepository, networkService: NetworkService, persistanceDataSource: DownloadsPersistanceDataSource) {
        self.appRepository = appRepository
        self.networkService = networkService
        self.persistanceDataSource = persistanceDataSource
    }
}

extension DownloadsRepositoryImpl: DownloadsRepository {
    func getPDF(userId: String, requestComponents: RequestComponents, cache: Bool) throws -> RepositoryResponse<PDFDocumentDTO> {
        if cache, let persisted = persistanceDataSource.getPDF(url: (userId + requestComponents.identifier).md5() ) {
            return LocalResponse(persisted)
        }
        let request = DownloadsPDFRequest(components: requestComponents)
        let serviceResponse = try networkService.executeCall(request: request)
        if validPdfData(serviceResponse.data.data ) {
            persistanceDataSource.setPDF(url: (userId + requestComponents.identifier).md5(), document: serviceResponse.data)
        }
        return LocalResponse(serviceResponse.data)
    }
}

private extension DownloadsRepositoryImpl {
    /// Validate that content of Data include the sign of a pdf file
    /// - Parameter data: buffer of data to be evaluated
    func validPdfData(_ data: Data) -> Bool {
        var isPDF: Bool = false
        if data.count >= 1024 //pdf headers are on the first 1kB of document
        {
            let pdfBytes: [UInt8] = [0x25, 0x50, 0x44, 0x46] // https://www.garykessler.net/library/file_sigs.html
            let pdfHeader = Data(bytes: pdfBytes, count: 4)
            let dataRange: Range<Data.Index> = 0..<1024
            if let foundRange = data.range(of: pdfHeader, options: Data.SearchOptions(), in: dataRange) {
                if foundRange.isNotEmpty {
                    isPDF = true
                }
            }
        }
        return isPDF
    }
}
