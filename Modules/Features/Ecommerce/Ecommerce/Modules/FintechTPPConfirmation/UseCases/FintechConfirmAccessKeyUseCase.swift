import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class FintechConfirmAccessKeyUseCase: UseCase<FintechConfirmAccessKeyUseCaseInput, FintechConfirmAccessKeyUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: FintechConfirmAccessKeyUseCaseInput) throws -> UseCaseResponse<FintechConfirmAccessKeyUseCaseOkOutput, StringErrorOutput> {
        let authenticateInput = generateAuthenticateInput(requestValues)
        let accessKeyParams = generateAccessKeyParams(requestValues)
        let response = try self.provider.getBsanFintechManager().confirmWithAccessKey(
            authenticationParams: authenticateInput,
            userInfo: accessKeyParams)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return try handlerError(response.getErrorMessage())
        }
        return .ok(FintechConfirmAccessKeyUseCaseOkOutput(urlLocation: data.location))
    }
}

private extension FintechConfirmAccessKeyUseCase {
    func handlerError(_ error: String?) throws -> UseCaseResponse<FintechConfirmAccessKeyUseCaseOkOutput, StringErrorOutput> {
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

    func generateAuthenticateInput(_ input: FintechConfirmAccessKeyUseCaseInput) -> FintechUserAuthenticationInputParams {
        return FintechUserAuthenticationInputParams(clientId: input.userAuthentication.clientId,
                                                    responseType: input.userAuthentication.responseType,
                                                    state: input.userAuthentication.state,
                                                    scope: input.userAuthentication.scope,
                                                    redirectUri: input.userAuthentication.redirectUri,
                                                    magicPhrase: input.userAuthentication.magicPhrase)
    }

    func generateAccessKeyParams(_ input: FintechConfirmAccessKeyUseCaseInput) -> FintechUserInfoAccessKeyParams {
        return FintechUserInfoAccessKeyParams(authenticationType: input.userInfo.authenticationType,
                                              documentType: input.userInfo.documentType,
                                              documentNumber: input.userInfo.documentNumber,
                                              magic: input.userInfo.magic)
    }
}

struct FintechConfirmAccessKeyUseCaseInput {
    let userAuthentication: FintechUserAuthenticationRepresentable
    let userInfo: FintechUserInfoAccessKeyRepresentable
}

struct FintechConfirmAccessKeyUseCaseOkOutput {
    let urlLocation: String
}
