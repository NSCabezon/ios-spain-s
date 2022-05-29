import Foundation
import CoreFoundationLib
import SANLibraryV3
import SANLegacyLibrary

final class QuickBalanceAccountUseCase: UseCase<QuickBalanceAccountUseCaseInput, QuickBalanceAccountUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let bsanManagersProvider: SANLibraryV3.BSANManagersProvider
    private let appConfig: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.bsanManagersProvider = self.dependenciesResolver.resolve(for: SANLibraryV3.BSANManagersProvider.self)
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
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
    
    private func loadGlobalPosition(isPb: Bool) throws -> UseCaseResponse<QuickBalanceAccountsData, StringErrorOutput> {
        let bsanResponse = try bsanManagersProvider.getBsanPGManager().loadGlobalPosition(onlyVisibleProducts: true, isPB: isPb)
        if bsanResponse.isSuccess(), let globalPosition = try bsanResponse.getResponseData() {
            guard let userDataDTO = globalPosition.userDataDTO, let userType = userDataDTO.clientPersonType, let userCode = userDataDTO.clientPersonCode else {
                return UseCaseResponse.error(StringErrorOutput(nil))
            }
            let userId = userType + userCode
            let accounts = getAccounts(userId: userId, globalPosition: globalPosition)
            let counterValueEnabled = appConfig.getBool("enabledCounterValue") == true
            let amountDecimal = getAmount(accounts: accounts, counterValueEnabled: counterValueEnabled) ?? 0
            let amount = AmountEntity(AmountDTO(value: amountDecimal, currency: CurrencyDTO.create(CoreCurrencyDefault.default)))
            return UseCaseResponse.ok(QuickBalanceAccountsData(amount: amount, accounts: accounts ?? []))
        } else if try isWrongUserTypeError(bsanResponse) {
            return try loadGlobalPosition(isPb: !isPb)
        }
        let error = try bsanResponse.getErrorMessage()
        return UseCaseResponse.error(StringErrorOutput(error))
    }
    
    private func getAccounts(userId: String, globalPosition: GlobalPositionDTO) -> [AccountEntity]? {
        let appRepository: AppRepositoryProtocol = self.dependenciesResolver.resolve()
        let userPrefs = appRepository.getUserPreferences(userId: userId)
        let accounts = globalPosition.accounts?.map {AccountEntity($0)}.filter {
            return userPrefs.pgUserPrefDTO.boxes[.account]?.getItem(withIdentifier: $0.productIdentifier)?.isVisible ?? true && $0.isAccountHolder()
        }
        return accounts
    }
    
    private func loadSca() throws -> ScaState {
        guard appConfig.getBool("enabledCounterValue") == true else {
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

    private func getAmount(accounts: [AccountEntity]?, counterValueEnabled: Bool) -> Decimal? {
        return (try? accounts?.compactMap {
            if counterValueEnabled {
                if let value = $0.getCounterValueAmountValue() {
                    return value
                } else if $0.getAmount()?.dto.currency?.currencyType == CoreCurrencyDefault.default {
                    return $0.getAmount()?.dto.value
                } else {
                    return nil
                }
            } else {
                guard $0.getAmount()?.dto.currency?.currencyType == CoreCurrencyDefault.default else {
                    throw MultipleCurrencyException()
                }
                return $0.getAmount()?.dto.value
            }
            }.reduce(Decimal(0.0)) { $0 + $1 }) ?? nil
    }
    
    override func executeUseCase(requestValues: QuickBalanceAccountUseCaseInput) throws -> UseCaseResponse<QuickBalanceAccountUseCaseOkOutput, StringErrorOutput> {
        let response = try loadGlobalPosition(isPb: requestValues.isPb)
        guard response.isOkResult else {
            let message: StringErrorOutput = try response.getErrorResult()
            return UseCaseResponse.error(message)
        }
        let data: QuickBalanceAccountsData = try response.getOkResult()
        let okOutput: QuickBalanceAccountUseCaseOkOutput
        switch try loadSca() {
        case .notApply:
            okOutput = .globalPosition(amount: data.amount, accounts: data.accounts)
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

struct QuickBalanceAccountUseCaseInput {
    let isPb: Bool
}

enum QuickBalanceAccountUseCaseOkOutput {
    case globalPosition(amount: AmountEntity, accounts: [AccountEntity])
    case scaTemporaryLock
    case scaRequestOtp
    case scaRequestOtpFirstTime
}

private struct QuickBalanceAccountsData {
    let amount: AmountEntity
    let accounts: [AccountEntity]
}

private enum ScaState {
    case notApply
    case temporaryLock
    case requestOtp
    case requestOtpFirstTime
}

private class MultipleCurrencyException: Error {
}
