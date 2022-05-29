import CoreFoundationLib
import SANLegacyLibrary

class GetRecoverPasswordUrlUseCase: UseCase<Void, GetRecoverPasswordUrlUseCaseOkOutput, StringErrorOutput> {
    private let bsanManagersProvider: BSANManagersProvider

    init(dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetRecoverPasswordUrlUseCaseOkOutput, StringErrorOutput> {
        guard let bsanEnvironmentDto = try bsanManagersProvider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        return UseCaseResponse.ok(GetRecoverPasswordUrlUseCaseOkOutput(recoverPasswordUrl: bsanEnvironmentDto.urlForgotMagic))
    }
}

struct GetRecoverPasswordUrlUseCaseOkOutput {
    let recoverPasswordUrl: String?
}
