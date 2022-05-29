import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class DestinationTypeSendMoneyTransferUseCase: UseCase<DestinationTypeSendMoneyTransferUseCaseInput, DestinationTypeSendMoneyTransferUseCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: DestinationTypeSendMoneyTransferUseCaseInput) throws -> UseCaseResponse<DestinationTypeSendMoneyTransferUseCaseOkOutput, StringErrorOutput> {
        let manager: TransfersRepository = dependenciesResolver.resolve()
        let response = try manager.transferType(originAccount: requestValues.account,
                                                selectedCountry: requestValues.countryInfo.code,
                                                selectedCurrerncy: requestValues.currencyInfo.code)
        switch response {
        case .success(let data):
            return UseCaseResponse.ok(DestinationTypeSendMoneyTransferUseCaseOkOutput(type: OnePayTransferType.from(data)))
        case .failure(let error):
            return .error(DestinationTypeSendMoneyTransferUseCaseErrorOutput(.invalid))
        }
    }
}

public struct DestinationTypeSendMoneyTransferUseCaseInput {
    let amount: AmountRepresentable?
    let currencyInfo: CurrencyInfoRepresentable
    let countryInfo: CountryInfoRepresentable
    let account: AccountRepresentable
}

public struct DestinationTypeSendMoneyTransferUseCaseOkOutput {
    let type: OnePayTransferType
}

public enum DestinationSendMoneyTransferError {
    case empty
    case zero
    case invalid
}

public class DestinationTypeSendMoneyTransferUseCaseErrorOutput: StringErrorOutput {
    public let error: DestinationSendMoneyTransferError
    
    init(_ error: DestinationSendMoneyTransferError) {
        self.error = error
        super.init("")
    }
}
