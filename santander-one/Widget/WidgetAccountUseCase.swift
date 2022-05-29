import Foundation
import CoreFoundationLib
import SANLibraryV3
import SANLegacyLibrary
import RetailLegacy

class WidgetAccountUseCase: UseCase<WidgetAccountUseCaseInput, WidgetAccountUseCaseOkOutput, StringErrorOutput> {
    private let bsanManagersProvider: SANLibraryV3.BSANManagersProvider
    private let daoUserPref: DAOUserPref
    private let daoSharedAppConfig: DAOSharedAppConfig
    
    init(bsanManagersProvider: SANLibraryV3.BSANManagersProvider, daoUserPref: DAOUserPref, daoSharedAppConfig: DAOSharedAppConfig) {
        self.bsanManagersProvider = bsanManagersProvider
        self.daoUserPref = daoUserPref
        self.daoSharedAppConfig = daoSharedAppConfig
        super.init()
    }
    
    private func isPbUserError(_ bsanResponse: BSANResponse<GlobalPositionDTO>) throws -> Bool {
        return try bsanResponse.getErrorCode().uppercased() == "1"
            && bsanResponse.getErrorMessage()?.uppercased().contains("SANTANDER PRIVATE BANKING") ?? false
    }
    
    private func isRetailUserError(_ bsanResponse: BSANResponse<GlobalPositionDTO>) throws -> Bool {
        return try bsanResponse.getErrorCode().uppercased() == "1"
            && bsanResponse.getErrorMessage()?.uppercased().contains("SANTANDER BANCA PARTICULARES") ?? false
    }
    
    private func isWrongUserTypeError(_ bsanResponse: BSANResponse<GlobalPositionDTO>) throws -> Bool {
        return try isPbUserError(bsanResponse) || isRetailUserError(bsanResponse)
    }
    
    private func loadGlobalPosition(isPb: Bool) throws -> UseCaseResponse<WidgetAccountsData, StringErrorOutput> {
        let bsanResponse = try bsanManagersProvider.getBsanPGManager().loadGlobalPosition(onlyVisibleProducts: true, isPB: isPb)
        if bsanResponse.isSuccess(), let globalPosition = try bsanResponse.getResponseData() {
            guard let userDataDTO = globalPosition.userDataDTO, let userType = userDataDTO.clientPersonType, let userCode = userDataDTO.clientPersonCode else {
                return UseCaseResponse.error(StringErrorOutput(nil))
            }
            let userId = userType + userCode
            let userPrefs = daoUserPref.get()
            let accounts = globalPosition.accounts?.map {Account(accountDTO: $0)}.filter {
                return userPrefs.getUserPrefDTO(userId: userId).pgUserPrefDTO.accountsBox.getItem(withIdentifier: $0.productIdentifier)?.isVisible ?? true && $0.isAccountHolder()
            }
            let counterValueEnabled = daoSharedAppConfig.get().isEnabledCounterValue ?? false
            let amountDecimal = getAmount(accounts: accounts, counterValueEnabled: counterValueEnabled) ?? 0
            let amount = Amount(amountDTO: AmountDTO(value: amountDecimal, currency: CurrencyDTO.create(CurrencyType.eur)))
            return UseCaseResponse.ok(WidgetAccountsData(amount: amount, accounts: accounts ?? []))
        } else if (try isWrongUserTypeError(bsanResponse)) {
            return try loadGlobalPosition(isPb: !isPb)
        }
        let error = try bsanResponse.getErrorMessage()
        return UseCaseResponse.error(StringErrorOutput(error))
    }
    
    private func loadSca() throws -> ScaState {
        guard daoSharedAppConfig.get().isEnabledCheckSca ?? false else {
            return .notApply
        }
        let scaManager: BSANScaManager = bsanManagersProvider.getBsanScaManager()
        let response: BSANResponse<CheckScaDTO> = try scaManager.checkSca()
        guard response.isSuccess(), let checkScaDTO: CheckScaDTO = try response.getResponseData(), let loginIndicator: ScaLoginState =  checkScaDTO.loginIndicator else {
            return .notApply
        }
        switch loginIndicator {
        case .notApply, .notPhone:
            return .notApply
        case .temporaryLock:
            return .temporaryLock
        case .requestOtp:
            return .requestOtp
        case .requestOtpFirstTime:
            return .requestOtpFirstTime
        }
    }

    private func getAmount(accounts: [Account]?, counterValueEnabled: Bool) -> Decimal? {
        return (try? accounts?.compactMap {
            if counterValueEnabled {
                if let value = $0.getCounterValueAmountValue() {
                    return value
                } else if $0.getAmount()?.amountDTO.currency?.currencyType == .eur {
                    return $0.getAmount()?.amountDTO.value
                } else {
                    return nil
                }
            } else {
                guard $0.getAmount()?.amountDTO.currency?.currencyType == .eur else {
                    throw MultipleCurrencyException()
                }
                return $0.getAmount()?.amountDTO.value
            }
            }.reduce(Decimal(0.0)) { $0 + $1 }) ?? nil
    }
    
    override func executeUseCase(requestValues: WidgetAccountUseCaseInput) throws -> UseCaseResponse<WidgetAccountUseCaseOkOutput, StringErrorOutput> {
        let response = try loadGlobalPosition(isPb: requestValues.isPb)
        guard response.isOkResult else {
            let message: StringErrorOutput = try response.getErrorResult()
            return UseCaseResponse.error(message)
        }
        let data: WidgetAccountsData = try response.getOkResult()
        let okOutput: WidgetAccountUseCaseOkOutput
        switch try loadSca() {
        case .notApply:
            okOutput = .pg(amount: data.amount, accounts: data.accounts)
        case .temporaryLock:
            okOutput = .scaTemporaryLock
        case .requestOtp:
             okOutput = .scaRequestOtp
        case .requestOtpFirstTime:
             okOutput = .scaRequestOtpFirstTime
        }
        return UseCaseResponse.ok(okOutput)
    }
}

struct WidgetAccountUseCaseInput {
    let isPb: Bool
}

fileprivate struct WidgetAccountsData {
    let amount: Amount
    let accounts: [Account]
}

fileprivate enum ScaState {
    case notApply
    case temporaryLock
    case requestOtp
    case requestOtpFirstTime
}

enum WidgetAccountUseCaseOkOutput {
    case pg(amount: Amount, accounts: [Account])
    case scaTemporaryLock
    case scaRequestOtp
    case scaRequestOtpFirstTime
}
