import SANLegacyLibrary
import CoreFoundationLib

class SetupPeriodicalContributionUseCase: SetupUseCase<SetupPeriodicalContributionUseCaseInput, SetupPeriodicalContributionUseCaseOKOutput, SetupPeriodicalContributionUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(repository: AppConfigRepository, managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
        super.init(appConfigRepository: repository)
    }
    
    override func executeUseCase(requestValues: SetupPeriodicalContributionUseCaseInput) throws -> UseCaseResponse<SetupPeriodicalContributionUseCaseOKOutput, SetupPeriodicalContributionUseCaseErrorOutput> {
        
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        
        let pensionsManager = provider.getBsanPensionsManager()
        let pensionDTO = requestValues.pension.pensionDTO
        var account: Account?
        
        let response = try pensionsManager.getAllPensionContributions(pensionDTO: pensionDTO)
        
        guard response.isSuccess(), let contributionsList = try response.getResponseData(), let pensionAccountAssociated = contributionsList.pensionInfoOperationDTO.pensionAccountAssociated else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(SetupPeriodicalContributionUseCaseErrorOutput(errorDescription))
        }
        
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: pensionAccountAssociated)
        if accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData() {
            account = Account.create(accountDTO)
        }
   
        let allowOperative = (contributionsList.pensionContributions?.first { $0.statusPlan == "AC" }) == nil
        return UseCaseResponse.ok(SetupPeriodicalContributionUseCaseOKOutput(allowOperative: allowOperative, pensionInfoOperation: PensionInfoOperation(contributionsList.pensionInfoOperationDTO), account: account, operativeConfig: operativeConfig))
    }
}

struct SetupPeriodicalContributionUseCaseInput {
    let pension: Pension
}

struct SetupPeriodicalContributionUseCaseOKOutput {
    let allowOperative: Bool
    let pensionInfoOperation: PensionInfoOperation
    let account: Account?
    var operativeConfig: OperativeConfig
}

extension SetupPeriodicalContributionUseCaseOKOutput: SetupUseCaseOkOutputProtocol {}
extension SetupPeriodicalContributionUseCase: AssociatedAccountRetriever {}

class SetupPeriodicalContributionUseCaseErrorOutput: StringErrorOutput {
    
}
