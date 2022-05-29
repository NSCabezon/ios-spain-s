//

import Foundation

enum DocumentsRepositoryError: Error {
    case errorSavingData
}

protocol DocumentsRepository {
    func save(fileName: String, data: Data) throws -> RepositoryResponse<URL>
}
