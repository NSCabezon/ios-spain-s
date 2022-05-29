import CoreFoundationLib

public final class IbanLocalValidationSendMoneyUseCase: UseCase<IbanValidationSendMoneyUseCaseInput, IbanValidationSendMoneyUseCaseOkOutput, DestinationAccountSendMoneyUseCaseErrorOutput>, IbanValidationSendMoneyUseCaseProtocol {
    private var bankingUtils: BankingUtilsProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.bankingUtils = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: IbanValidationSendMoneyUseCaseInput) throws -> UseCaseResponse<IbanValidationSendMoneyUseCaseOkOutput, DestinationAccountSendMoneyUseCaseErrorOutput> {
        guard let ibanString = requestValues.iban?.ibanString, !ibanString.isEmpty, bankingUtils.isValidIban(ibanString: ibanString) else {
            return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.ibanInvalid))
        }
        
        guard let name = requestValues.name, name.trim().count > 0 else {
            return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.noToName))
        }
        if requestValues.saveFavorites {
            guard let alias = requestValues.alias?.lowercased().trim(),
                    alias.count > 0 else {
                return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.noAlias))
            }
            let duplicate = requestValues.favouriteList.first { return $0.payeeAlias?.lowercased().trim() == alias.trim() }
            guard duplicate == nil else {
                return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.duplicateAlias))
            }
        }
        return .ok(.empty)
    }
}
