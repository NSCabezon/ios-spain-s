import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class SaveFileUseCase: UseCase<SaveFileUseCaseInput, SaveFileUseCaseOkOutput, StringErrorOutput> {
    
    private let documentsRepository: DocumentsRepository
    
    init(documentsRepository: DocumentsRepository) {
        self.documentsRepository = documentsRepository
    }
    
    override func executeUseCase(requestValues: SaveFileUseCaseInput) throws -> UseCaseResponse<SaveFileUseCaseOkOutput, StringErrorOutput> {
        let response = try self.documentsRepository.save(fileName: requestValues.fileName, data: requestValues.data)
        guard response.isSuccess(), let url = try response.getResponseData() else { return .error(StringErrorOutput(try response.getErrorMessage())) }
        return .ok(SaveFileUseCaseOkOutput(url: url))
    }
}

struct SaveFileUseCaseInput {
    let data: Data
    let fileName: String
}

struct SaveFileUseCaseOkOutput {
    let url: URL
}
