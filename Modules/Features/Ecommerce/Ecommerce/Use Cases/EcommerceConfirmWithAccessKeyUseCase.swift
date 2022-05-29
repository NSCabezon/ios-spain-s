import CoreFoundationLib
import SANLegacyLibrary

public final class EcommerceConfirmWithAccessKeyUseCase: UseCase<EcommerceConfirmWithAccessKeyUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override public func executeUseCase(requestValues: EcommerceConfirmWithAccessKeyUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let accessKeyBase64 = requestValues.accessKey.getEncodeString(withOptions: Data.Base64EncodingOptions(rawValue: 0)) ?? ""
        let shorUrl = requestValues.shortUrl
        let response = try provider.getBsanEcommerceManager().confirmWithAccessKey(shortUrl: shorUrl, key: accessKeyBase64)
        guard !response.isSuccess() else {
            return .ok()
        }
        guard let errorMessage = try response.getErrorMessage(),
              let data = errorMessage.data(using: .utf8),
              let parsedError = try? JSONDecoder().decode(EcommerceConfirmationError.self, from: data),
              let foundError = parsedError.descError.first(where: { $0.language.lowercased() == "es" })
        else {
            return .error(StringErrorOutput(nil))
        }
        return .error(StringErrorOutput(foundError.value))
    }
}

public struct EcommerceConfirmWithAccessKeyUseCaseInput {
    let shortUrl: String
    let accessKey: String
}
