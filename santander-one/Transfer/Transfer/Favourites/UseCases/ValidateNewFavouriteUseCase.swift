import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public protocol ValidateNewFavouriteUseCaseProtocol: UseCase<ValidateNewFavouriteUseCaseInput, ValidateNewFavouriteUseCaseOkOutput, StringErrorOutput> { }

public final class ValidateNewFavouriteUseCase: UseCase<ValidateNewFavouriteUseCaseInput, ValidateNewFavouriteUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: ValidateNewFavouriteUseCaseInput) throws -> UseCaseResponse<ValidateNewFavouriteUseCaseOkOutput, StringErrorOutput> {
        guard let ibanDTO = requestValues.iban?.dto else {
            return .error(StringErrorOutput(nil))
        }
        let alias = requestValues.alias
        let beneficiaryName = requestValues.beneficiaryName
        let recipientType: FavoriteRecipientType
        if ibanDTO.countryCode.uppercased() == "ES" {
            recipientType = .national
        } else {
            recipientType = .international
        }
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let response = try provider.getBsanTransfersManager().validateCreateSepaPayee(alias: alias, recipientType: recipientType, beneficiary: beneficiaryName, iban: ibanDTO, serviceType: nil, contractType: nil, accountIdType: nil, accountId: nil, streetName: nil, townName: nil, location: nil, country: nil, operationDate: Date())
        guard
            response.isSuccess(),
            let signatureWithTokenDTO = try response.getResponseData(),
            let signature = signatureWithTokenDTO,
            let signatureWithToken = SignatureWithTokenEntity(signature) else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        return .ok(ValidateNewFavouriteUseCaseOkOutput(signatureWithToken: signatureWithToken))
    }
}

public struct ValidateNewFavouriteUseCaseInput {
    public let alias: String
    public let beneficiaryName: String
    public let iban: IBANEntity?
    public let accountId: String?
    public let country: String?
    
    public init(
        alias: String,
        beneficiaryName: String,
        iban: IBANEntity? = nil,
        accountId: String? = nil,
        country: String? = nil) {
        self.alias = alias
        self.beneficiaryName = beneficiaryName
        self.iban = iban
        self.accountId = accountId
        self.country = country
    }
}

public struct ValidateNewFavouriteUseCaseOkOutput {
    let signatureWithToken: SignatureWithTokenEntity?
    
    public init(signatureWithToken: SignatureWithTokenEntity? = nil) {
        self.signatureWithToken = signatureWithToken
    }
}

extension ValidateNewFavouriteUseCase: ValidateNewFavouriteUseCaseProtocol { }
