import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class GetTempPdfUseCase: UseCase<GetTempPdfUseCaseInput, GetTempPdfUseCaseOkOutput, StringErrorOutput> {
    private let documentsRepository: DocumentsRepository
    
    init(documentsRepository: DocumentsRepository) {
        self.documentsRepository = documentsRepository
    }
    
    override func executeUseCase(requestValues: GetTempPdfUseCaseInput) throws -> UseCaseResponse<GetTempPdfUseCaseOkOutput, StringErrorOutput> {
        let response = try documentsRepository.save(fileName: requestValues.newFilename, data: requestValues.data)
        guard response.isSuccess(), let responseData = try response.getResponseData() else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        return UseCaseResponse.ok(GetTempPdfUseCaseOkOutput(pdfDocument: responseData))
    }
}

struct GetTempPdfUseCaseInput {
    let data: Data
    let newFilename: String
}

struct GetTempPdfUseCaseOkOutput {
    let pdfDocument: URL
}
