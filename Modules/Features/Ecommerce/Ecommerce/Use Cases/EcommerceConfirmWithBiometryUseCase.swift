import CoreFoundationLib
import SANLegacyLibrary

final class EcommerceConfirmWithBiometryUseCase: UseCase<EcommerceConfirmWithBiometryUseCaseInput, Void, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: EcommerceConfirmWithBiometryUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let response = try provider.getBsanEcommerceManager().confirmWithFingerPrint(
            input: EcommerceConfirmWithFingerPrintInputParams(
                shortUrl: requestValues.shortUrl,
                token: requestValues.deviceToken,
                footprint: requestValues.fingerprint
            )
        )
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

struct EcommerceConfirmWithBiometryUseCaseInput {
    let shortUrl: String
    let fingerprint: String
    let deviceToken: String
}
