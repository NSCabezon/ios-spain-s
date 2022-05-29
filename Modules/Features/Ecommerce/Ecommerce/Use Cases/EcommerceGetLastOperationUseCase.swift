import CoreFoundationLib
import SANLegacyLibrary

public final class EcommerceGetLastOperationUseCase: UseCase<EcommerceGetLastOperationUseCaseInput, EcommerceGetLastOperationUseCaseOutput, StringErrorOutput> {
    private let secondsInAMinute: Int = 60
    private let provider: BSANManagersProvider
    private let appRepository: AppRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appRepository = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: EcommerceGetLastOperationUseCaseInput) throws -> UseCaseResponse<EcommerceGetLastOperationUseCaseOutput, StringErrorOutput> {
        let persistedUser = try? appRepository.getPersistedUser().getResponseData()
        let tempUserLoginType = try? appRepository.getTempUserType().getResponseData()
        let tempLogin = try? appRepository.getTempLogin().getResponseData()
        guard let documentType = persistedUser?.loginType.name ?? tempUserLoginType?.name,
              let documentNumber = persistedUser?.login ?? tempLogin,
              let tokenPush = requestValues.tokenPush
        else { return .error(StringErrorOutput(nil)) }
        let deviceToken = tokenPush.map { String(format: "%02.2hhx", $0) }.joined()
        let response = try provider.getBsanEcommerceManager().getLastOperationShortUrl(
            documentType: documentType,
            documentNumber: documentNumber,
            tokenPush: deviceToken
        )
        guard response.isSuccess(), let shortUrlDto = try response.getResponseData() else {
            let errorMessage = try response.getErrorMessage()
            return .error(StringErrorOutput(errorMessage))
        }
        let ecommerceCode = shortUrlDto.shortUrl
        let lastPurchaseInfo = EcommerceLastPurchaseInfo(code: ecommerceCode, remainingTime: nil)
        return UseCaseResponse.ok(EcommerceGetLastOperationUseCaseOutput(lastPurchaseInfo: lastPurchaseInfo))
    }
}

public struct EcommerceGetLastOperationUseCaseInput {
    let tokenPush: Data?
}

public struct EcommerceGetLastOperationUseCaseOutput {
    let lastPurchaseInfo: EcommerceLastPurchaseInfo
}
