import CoreFoundationLib
import SANLegacyLibrary

class GetDetailLiquidationUseCase: UseCase<GetDetailLiquidationUseCaseInput, GetDetailLiquidationUseCaseOkOutput, GetDetailLiquidationUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetDetailLiquidationUseCaseInput) throws -> UseCaseResponse<GetDetailLiquidationUseCaseOkOutput, GetDetailLiquidationUseCaseErrorOutput> {
        
        let impositionManager = provider.getBsanDepositsManager()
        
        let response = try impositionManager.getLiquidationDetail(impositionDTO: requestValues.impositionDTO, liquidationDTO: requestValues.liquidationDTO)
        
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(GetDetailLiquidationUseCaseErrorOutput(errorDescription))
        }
        
        return UseCaseResponse.ok(GetDetailLiquidationUseCaseOkOutput(liquidationDetailList: LiquidationDetailList(data)))
    }
    
}

struct GetDetailLiquidationUseCaseInput {
    let impositionDTO: ImpositionDTO
    let liquidationDTO: LiquidationDTO
}

struct GetDetailLiquidationUseCaseOkOutput {
    let liquidationDetailList: LiquidationDetailList
}

class GetDetailLiquidationUseCaseErrorOutput: StringErrorOutput { }
