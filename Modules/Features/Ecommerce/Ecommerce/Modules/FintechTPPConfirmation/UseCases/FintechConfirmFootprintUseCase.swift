import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class FintechConfirmFootprintUseCase: UseCase<FintechConfirmaFootprintUseCaseInput, FintechConfirmaFootprintUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: FintechConfirmaFootprintUseCaseInput) throws -> UseCaseResponse<FintechConfirmaFootprintUseCaseOkOutput, StringErrorOutput> {
        let authenticateInput = generateAuthenticateInput(requestValues)
        let accessKeyParams = generateAccessKeyParams(requestValues)
        let response = try self.provider.getBsanFintechManager().confirmWithFootprint(
            authenticationParams: authenticateInput,
            userInfo: accessKeyParams)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return try handlerError(response.getErrorMessage())
        }
        return .ok(FintechConfirmaFootprintUseCaseOkOutput(urlLocation: data.location))
    }
}

private extension FintechConfirmFootprintUseCase {
    func handlerError(_ error: String?) throws -> UseCaseResponse<FintechConfirmaFootprintUseCaseOkOutput, StringErrorOutput> {
        guard let errorMessage = error,
              let data = errorMessage.data(using: .utf8),
              let parsedError = try? JSONDecoder().decode(FintechConfirmationError.self, from: data)
        else {
            return .error(StringErrorOutput(nil))
        }
        let language = dependenciesResolver.resolve(for: StringLoader.self).getCurrentLanguage().appLanguageCode
        var error: StringErrorOutput = StringErrorOutput(nil)
        if let foundError = parsedError.description
            .filter({ $0.language.lowercased() == language }).first {
            error = StringErrorOutput(foundError.value)
        } else if let spanishError = parsedError.description.first(where: { $0.language.lowercased() == "es" }) {
            error = StringErrorOutput(spanishError.value)
        }
        return .error(error)
    }

    func generateAuthenticateInput(_ input: FintechConfirmaFootprintUseCaseInput) -> FintechUserAuthenticationInputParams {
        return FintechUserAuthenticationInputParams(clientId: input.userAuthentication.clientId,
                                                    responseType: input.userAuthentication.responseType,
                                                    state: input.userAuthentication.state,
                                                    scope: input.userAuthentication.scope,
                                                    redirectUri: input.userAuthentication.redirectUri,
                                                    magicPhrase: input.userAuthentication.magicPhrase)
    }

    func generateAccessKeyParams(_ input: FintechConfirmaFootprintUseCaseInput) -> FintechUserInfoFootprintParams {
        return FintechUserInfoFootprintParams(authenticationType: input.userInfo.authenticationType,
                                              documentType: input.userInfo.documentType,
                                              documentNumber: input.userInfo.documentNumber,
                                              deviceMagicPhrase: input.userInfo.deviceMagicPhrase,
                                              footprint: input.userInfo.footprint)
    }
}
struct FintechConfirmaFootprintUseCaseInput {
    let userAuthentication: FintechUserAuthenticationRepresentable
    let userInfo: FintechUserInfoFootprintRepresentable
}

struct FintechConfirmaFootprintUseCaseOkOutput {
    let urlLocation: String
}
