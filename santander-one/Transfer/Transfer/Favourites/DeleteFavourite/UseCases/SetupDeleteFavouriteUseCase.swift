import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import Foundation
import Operative

public protocol SetupDeleteFavouriteUseCaseProtocol: UseCase<SetupDeleteFavouriteUseCaseInput, SetupDeleteFavouriteUseCaseOKOutput, StringErrorOutput> { }

final class SetupDeleteFavouriteUseCase: UseCase<SetupDeleteFavouriteUseCaseInput, SetupDeleteFavouriteUseCaseOKOutput, StringErrorOutput> {
    private let dependencies: DependenciesResolver
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    override func executeUseCase(requestValues: SetupDeleteFavouriteUseCaseInput) throws -> UseCaseResponse<SetupDeleteFavouriteUseCaseOKOutput, StringErrorOutput> {
        guard let favourite = requestValues.favourite,
              let alias = favourite.payeeDisplayName,
              let payeeCode = favourite.payeeCode,
              let recipientType = favourite.recipientType,
              let accountType = favourite.accountType
        else { return UseCaseResponse.error(StringErrorOutput(nil)) }
        let provider = self.dependencies.resolve(for: BSANManagersProvider.self)
        let response = try provider.getBsanTransfersManager().validateRemoveSepaPayee(ofAlias: alias, payeeCode: payeeCode, recipientType: recipientType, accountType: accountType)
        guard response.isSuccess(),
            let signatureWithTokenDTO = try response.getResponseData(),
            let signatureWithToken = SignatureWithTokenEntity(signatureWithTokenDTO) else {
                let errorDescription = try response.getErrorMessage() ?? ""
                return .error(StringErrorOutput(errorDescription))
        }
        return .ok(SetupDeleteFavouriteUseCaseOKOutput(signatureWithToken: signatureWithToken, predefinedSCA: .signature))
    }
}

public struct SetupDeleteFavouriteUseCaseInput {
    let favourite: PayeeRepresentable?
}

public struct SetupDeleteFavouriteUseCaseOKOutput {
    let signatureWithToken: SignatureWithTokenEntity?
    let predefinedSCA: PredefinedSCAEntity?
    
    public init(signatureWithToken: SignatureWithTokenEntity? = nil, predefinedSCA: PredefinedSCAEntity? = nil) {
        self.signatureWithToken = signatureWithToken
        self.predefinedSCA = predefinedSCA
    }
}

extension SetupDeleteFavouriteUseCase: SetupDeleteFavouriteUseCaseProtocol { }
