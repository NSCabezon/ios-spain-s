import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class GetPdfUseCase: UseCase<GetPdfUseCaseInput, GetPdfUseCaseOkOutput, StringErrorOutput> {
    private let bsanProvider: BSANManagersProvider
    private let downloadsRepository: DownloadsRepository
    
    init(bsanProvider: BSANManagersProvider, downloadsRepository: DownloadsRepository) {
        self.bsanProvider = bsanProvider
        self.downloadsRepository = downloadsRepository
    }
    
    override func executeUseCase(requestValues: GetPdfUseCaseInput) throws -> UseCaseResponse<GetPdfUseCaseOkOutput, StringErrorOutput> {
        let userResponse = try bsanProvider.getBsanPGManager().getGlobalPosition()
        guard userResponse.isSuccess(), let userDataDTO = try userResponse.getResponseData()?.userDataDTO, let userId = UserDO(dto: userDataDTO).userId else {
            let error = try userResponse.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        let response = try downloadsRepository.getPDF(userId: userId, requestComponents: requestValues.requestComponents, cache: requestValues.cache)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        return UseCaseResponse.ok(GetPdfUseCaseOkOutput(pdfDocument: data.data))
    }
}

struct GetPdfUseCaseInput {
    let requestComponents: RequestComponents
    let cache: Bool
}

struct GetPdfUseCaseOkOutput {
    let pdfDocument: Data
}
