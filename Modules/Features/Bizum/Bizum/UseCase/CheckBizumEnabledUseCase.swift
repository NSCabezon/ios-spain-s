import CoreFoundationLib
import SANLibraryV3

public final class CheckBizumEnabledUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let environmentResponse = provider.getBsanEnvironmentsManager().getCurrentEnvironment()
        guard environmentResponse.isSuccess(),
            let bsanEnvironment = try provider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData(),
            bsanEnvironment.urlBizumWeb != nil
        else {
            return UseCaseResponse.error(StringErrorOutput(try environmentResponse.getErrorMessage()))
        }
        _ = try provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        return UseCaseResponse.ok()
    }
}
