import CoreFoundationLib
import SANLegacyLibrary

class GetCommercialSegmentUseCase: UseCase<Void, GetCommercialSegmentUseCaseOkOutput, StringErrorOutput> {
    private let appRepository: AppRepository
    
    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCommercialSegmentUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(GetCommercialSegmentUseCaseOkOutput(commercialSegment: try appRepository.getCommercialSegment().getResponseData()))
    }
}

struct GetCommercialSegmentUseCaseOkOutput {
    let commercialSegment: CommercialSegmentEntity?
}
