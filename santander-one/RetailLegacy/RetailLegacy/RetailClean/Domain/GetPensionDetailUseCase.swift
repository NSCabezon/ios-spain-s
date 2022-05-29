//

import SANLegacyLibrary
import CoreFoundationLib

class GetPensionDetailUseCase: UseCase<GetPensionDetailUseCaseInput, GetPensionDetailUseCaseOKOutput, GetPensionDetailUseCaseErrorOutput> {
    
    let provider: BSANManagersProvider
    
    init(managerProvider: BSANManagersProvider) {
        self.provider = managerProvider
    }
    
    override func executeUseCase(requestValues: GetPensionDetailUseCaseInput) throws -> UseCaseResponse<GetPensionDetailUseCaseOKOutput, GetPensionDetailUseCaseErrorOutput> {
        let bsanPensionManager = provider.getBsanPensionsManager()
        let pensionDTO = requestValues.pension.pensionDTO
        
        let response = try bsanPensionManager.getPensionDetail(forPension: pensionDTO)
        
        if response.isSuccess(), let detailDTO = try response.getResponseData() {
            let pensionDetail = PensionDetail(pensionDTO, detailDTO: detailDTO)
            return UseCaseResponse.ok(GetPensionDetailUseCaseOKOutput(pensionDetail: pensionDetail))
        }
        
        let errorResponse = try response.getErrorMessage()
        return UseCaseResponse.error(GetPensionDetailUseCaseErrorOutput(errorResponse))
    }
    
}

// MARK: - Input
struct GetPensionDetailUseCaseInput {
    let pension: Pension
    
    init(pension: Pension) { self.pension = pension }
}

// MARK: - OK output
struct GetPensionDetailUseCaseOKOutput {
    private let pensionDetail: PensionDetail
    init(pensionDetail: PensionDetail) {
        self.pensionDetail = pensionDetail
    }
    public func getPensionDetail() -> PensionDetail {
        return pensionDetail
    }
}

// MARK: - OK output
class GetPensionDetailUseCaseErrorOutput: StringErrorOutput {
    override init(_ errorDesc: String?) {
        super.init(errorDesc)
    }
}
