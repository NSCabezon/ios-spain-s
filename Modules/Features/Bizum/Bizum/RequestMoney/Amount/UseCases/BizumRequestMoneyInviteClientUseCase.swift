import CoreFoundationLib
import Operative
import SANLibraryV3

struct BizumRequestMoneyInviteClientUseCaseInput {
    let validateMoneyRequestEntity: BizumValidateMoneyRequestEntity
}

final class BizumRequestMoneyInviteClientUseCase: UseCase<BizumRequestMoneyInviteClientUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    override func executeUseCase(requestValues: BizumRequestMoneyInviteClientUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let input: BizumInviteNoClientInputParams = BizumInviteNoClientInputParams(validateMoneyRequestDTO: requestValues.validateMoneyRequestEntity.dto)
        let response = try provider.getBSANBizumManager().inviteNoClient(input)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage() ?? ""
             return .error(StringErrorOutput(errorDescription))
        }
        return UseCaseResponse.ok()
    }
}
