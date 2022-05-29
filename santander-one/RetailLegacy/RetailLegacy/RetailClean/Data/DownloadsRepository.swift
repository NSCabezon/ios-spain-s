import Foundation

protocol DownloadsRepository {
    func getPDF(userId: String, requestComponents: RequestComponents, cache: Bool) throws -> RepositoryResponse<PDFDocumentDTO>
}
