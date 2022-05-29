import SANLegacyLibrary
import CoreFoundationLib

class GetFundDetailUseCase: UseCase<GetFundDetailUseCaseInput, GetFundDetailUseCaseOKOutput, GetFundDetailUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetFundDetailUseCaseInput) throws -> UseCaseResponse<GetFundDetailUseCaseOKOutput, GetFundDetailUseCaseErrorOutput> {
        
        let bsanFundsManager = provider.getBsanFundsManager()
        let fundDTO = requestValues.fund.fundDTO
        
        let response = try bsanFundsManager.getFundDetail(forFund: fundDTO)
        
        if response.isSuccess(), let detailDTO = try response.getResponseData() {
            let funDetail = FundDetail.create(fundDTO, detailDTO: detailDTO)
            return UseCaseResponse.ok(GetFundDetailUseCaseOKOutput(fundDetail: funDetail))
        }
        
        let errorMessage = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetFundDetailUseCaseErrorOutput(errorMessage))
    }
}

// MARK: - Input
struct GetFundDetailUseCaseInput {
    let fund: Fund
    
    init(fund: Fund) { self.fund = fund }
}

// MARK: - OK Output
struct GetFundDetailUseCaseOKOutput {
    private let fundDetail: FundDetail
    func getFundDetail() -> FundDetail {
        return fundDetail
    }
    init(fundDetail: FundDetail) { self.fundDetail = fundDetail }
}

// MARK: - Error output
class GetFundDetailUseCaseErrorOutput: StringErrorOutput {
    override init(_ errorDesc: String?) {
        super.init(errorDesc)
    }
}
