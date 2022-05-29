import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import Foundation

public protocol PreValidateNewFavouriteUseCaseProtocol: UseCase<PreValidateNewFavouriteUseCaseInput, PreValidateNewFavouriteUseCaseOkOutput, PreValidateNewFavouriteUseCaseErrorOutput> { }

final class PreValidateNewFavouriteUseCase: UseCase<PreValidateNewFavouriteUseCaseInput, PreValidateNewFavouriteUseCaseOkOutput, PreValidateNewFavouriteUseCaseErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let bsanManagersProvider: BSANManagersProvider
    lazy var bankingUtils: BankingUtilsProtocol = {
        dependenciesResolver.resolve()
    }()
    
    init(bsanManagersProvider: BSANManagersProvider,
         dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = bsanManagersProvider
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: PreValidateNewFavouriteUseCaseInput) throws -> UseCaseResponse<PreValidateNewFavouriteUseCaseOkOutput, PreValidateNewFavouriteUseCaseErrorOutput> {
        let transferManager = bsanManagersProvider.getBsanTransfersManager()
        let responseUsualTransfer = try transferManager.getUsualTransfers()
        guard responseUsualTransfer.isSuccess(), let dataUsualTransfer = try responseUsualTransfer.getResponseData() else {
            let error = ErrorDescriptionType.key("generic_error_txt")
            return .error(PreValidateNewFavouriteUseCaseErrorOutput(error))
        }
        let usualTransfers = dataUsualTransfer
        guard let alias = requestValues.alias else {
            let error = ErrorDescriptionType.key("onePay_alert_alias")
            return .error(PreValidateNewFavouriteUseCaseErrorOutput(error))
        }
        guard usualTransfers.first(where: { $0.payeeDisplayName?.lowercased() == alias.lowercased() }) == nil else {
            let error = ErrorDescriptionType.keyWithPlaceHolder("onePay_alert_valueAlias", [StringPlaceholder(.value, alias)])
            return .error(PreValidateNewFavouriteUseCaseErrorOutput(error))
        }
        guard let ibanString = requestValues.iban,
              bankingUtils.isValidIban(ibanString: ibanString)
              else {
            let error = ErrorDescriptionType.key("onePay_alert_valueIban")
            return .error(PreValidateNewFavouriteUseCaseErrorOutput(error))
        }
        let ibanEntity = IBANEntity.create(fromText: ibanString)
        return .ok(PreValidateNewFavouriteUseCaseOkOutput(iban: ibanEntity, alias: alias))
    }
}

public struct PreValidateNewFavouriteUseCaseInput {
    public let iban: String?
    public let alias: String?
}

public struct PreValidateNewFavouriteUseCaseOkOutput {
    let iban: IBANEntity
    let alias: String
    
    public init(iban: IBANEntity, alias: String) {
        self.iban = iban
        self.alias = alias
    }
}

public final class PreValidateNewFavouriteUseCaseErrorOutput: StringErrorOutput {
    let errorInfo: ErrorDescriptionType
    
    public init(_ error: ErrorDescriptionType) {
        self.errorInfo = error
        super.init(nil)
    }
}

public enum ErrorDescriptionType {
    case key(String)
    case keyWithPlaceHolder(String, [StringPlaceholder])
}

extension PreValidateNewFavouriteUseCase: PreValidateNewFavouriteUseCaseProtocol { }
