import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class SetupPensionExtraordinaryContributionUseCase: SetupUseCase<SetupPensionExtraordinaryContributionUseCaseInput, SetupPensionExtraordinaryContributionUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupPensionExtraordinaryContributionUseCaseInput) throws -> UseCaseResponse<SetupPensionExtraordinaryContributionUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let pensionsManager = provider.getBsanPensionsManager()
        
        if let pension = requestValues.pension {
            let pensionDTO = pension.pensionDTO
            
            let response = try pensionsManager.getPensionContributions(pensionDTO: pensionDTO, pagination: nil)
            guard response.isSuccess(),
                let responseData = try response.getResponseData(),
                responseData.pensionInfoOperationDTO.pensionAccountAssociated != nil else {
                    return .error(SetupPensionExtraordinaryContributionUseCaseErrorOutput(try response.getErrorMessage()))
            }
            return .ok(SetupPensionExtraordinaryContributionUseCaseOkOutput(operativeConfig: operativeConfig))
        }
        return .error(StringErrorOutput(nil))
    }
}

struct SetupPensionExtraordinaryContributionUseCaseInput {
    let pension: Pension?
}

struct SetupPensionExtraordinaryContributionUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
}

class SetupPensionExtraordinaryContributionUseCaseErrorOutput: StringErrorOutput {}
