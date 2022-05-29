import CoreFoundationLib
import SANLegacyLibrary

class IsSameClientUseCase: UseCase<IsSameClientUseCaseInput, Void, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(provider: BSANManagersProvider) {
        self.provider = provider
    }
    
    override public func executeUseCase(requestValues: IsSameClientUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let client = requestValues.clientDO else { return .error(StringErrorOutput(nil)) }
        let response = try provider.getBsanPGManager().getGlobalPosition()
        guard response.isSuccess(), let user = try response.getResponseData()?.userDataDTO else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage()))
        }
        if user.clientPersonType == client.personType && user.clientPersonCode == client.personCode {
            return .ok()
        }
        return .error(StringErrorOutput(nil))
    }
}

struct IsSameClientUseCaseInput {
    let clientDO: ClientDO?
}
