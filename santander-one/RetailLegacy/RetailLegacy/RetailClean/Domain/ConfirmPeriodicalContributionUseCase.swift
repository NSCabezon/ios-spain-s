import SANLegacyLibrary
import CoreFoundationLib

class ConfirmPeriodicalContributionUseCase: ConfirmUseCase<ConfirmPeriodicalContributionUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider

    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmPeriodicalContributionUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let pensionsManager = provider.getBsanPensionsManager()
        let pensionDTO = requestValues.pension.pensionDTO
        let amountDTO = requestValues.amount.amountDTO
        let signatureWithToken = requestValues.signatureToken
        let signatureWithTokenDTO = SignatureWithTokenDTO(signatureDTO: signatureWithToken.signature.dto, magicPhrase: signatureWithToken.magicPhrase)
        let configuration = requestValues.contributionConfiguration
        let revaluation = configuration.revaluation.dto
        let contributionInput = PensionContributionInput(startDate: configuration.startDate, periodicyType: configuration.periodicity.dto, amountDTO: amountDTO, percentage: revaluation.percentage, revaluationType: revaluation.type)
        
        let response = try pensionsManager.confirmPeriodicalContribution(pensionDTO: pensionDTO, pensionContributionInput: contributionInput, signatureWithTokenDTO: signatureWithTokenDTO)

        if response.isSuccess() {
            return UseCaseResponse.ok()
        }
        let signatureType = try getSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmPeriodicalContributionUseCaseInput {
    let pension: Pension
    let amount: Amount
    let signatureToken: SignatureWithToken
    let contributionConfiguration: ContributionConfiguration
}

extension ContributionConfigurationPeriodicity {
    var dto: PeriodicityType {
        switch self {
        case .monthly:
            return .monthly
        case .quarterly:
            return .quarterly
        case .biannual:
            return .biannual
        case .annual:
            return .annual
        }
    }
}

extension ContributionConfigurationRevaluation {
    var dto: (type: RevaluationType, percentage: String) {
        switch self {
        case .none:
            return (.without_revaluation, "")
        case .accordingToIPC:
            return (.according_ipc, "")
        case .accordingToFixedPercentage(let percentage):
            return (.according_percentage, percentage)
        }
    }
}
