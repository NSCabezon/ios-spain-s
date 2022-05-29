import CoreFoundationLib
import SANLegacyLibrary
import Foundation

class DestinationOnePayTransferUseCase: UseCase<DestinationOnePayTransferUseCaseInput, DestinationOnePayTransferUseCaseOkOutput, DestinationOnePayTransferUseCaseErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.bsanManagersProvider = managersProvider
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: DestinationOnePayTransferUseCaseInput) throws -> UseCaseResponse<DestinationOnePayTransferUseCaseOkOutput, DestinationOnePayTransferUseCaseErrorOutput> {
        guard let stringData = requestValues.amount, !stringData.isEmpty else {
            return UseCaseResponse.error(DestinationOnePayTransferUseCaseErrorOutput(.empty))
        }
        guard let dataDecimal = stringData.stringToDecimal else {
            return UseCaseResponse.error(DestinationOnePayTransferUseCaseErrorOutput(.invalid))
        }
        guard dataDecimal > 0 else {
            return UseCaseResponse.error(DestinationOnePayTransferUseCaseErrorOutput(.zero))
        }
        let amount = Amount.create(value: dataDecimal, currency: requestValues.currencyInfo.currency)
        let response = try bsanManagersProvider.getBsanTransfersManager().transferType(originAccountDTO: requestValues.account.accountDTO, selectedCountry: requestValues.countryInfo.code, selectedCurrerncy: requestValues.currencyInfo.code)
        guard response.isSuccess(), let transferType = try response.getResponseData() else {
            return .error(DestinationOnePayTransferUseCaseErrorOutput(.invalid))
        }
        return UseCaseResponse.ok(DestinationOnePayTransferUseCaseOkOutput(amount: amount, type: OnePayTransferType.from(transferType)))
    }
}

struct DestinationOnePayTransferUseCaseInput {
    let amount: String?
    let currencyInfo: SepaCurrencyInfo
    let countryInfo: SepaCountryInfo
    let account: Account
}

struct DestinationOnePayTransferUseCaseOkOutput {
    let amount: Amount
    let type: OnePayTransferType
}

enum DestinationOnePayTransferError {
    case empty
    case zero
    case invalid
}

class DestinationOnePayTransferUseCaseErrorOutput: StringErrorOutput {
    let error: DestinationOnePayTransferError
    
    init(_ error: DestinationOnePayTransferError) {
        self.error = error
        super.init("")
    }
}
