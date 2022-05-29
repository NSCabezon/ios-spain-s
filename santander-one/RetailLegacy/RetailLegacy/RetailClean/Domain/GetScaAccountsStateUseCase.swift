import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetScaAccountsStateUseCase: UseCase<GetScaAccountsStateUseCaseInput, GetScaAccountsStateUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let backwardDays: Int = 89
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: GetScaAccountsStateUseCaseInput) throws -> UseCaseResponse<GetScaAccountsStateUseCaseOkOutput, StringErrorOutput> {
        let appConfigEnableSCAAccountTransactions = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableSCAAccountTransactions) ?? false
        guard appConfigEnableSCAAccountTransactions else {
            return UseCaseResponse.ok(GetScaAccountsStateUseCaseOkOutput.notApply)
        }
        let scaManager: BSANScaManager = provider.getBsanScaManager()
        let response: BSANResponse<CheckScaDTO> = try scaManager.checkSca()
        guard response.isSuccess(), let checkScaDTO: CheckScaDTO = try response.getResponseData(), let accountIndicator: ScaAccountState =  checkScaDTO.accountIndicator else {
            return UseCaseResponse.ok(GetScaAccountsStateUseCaseOkOutput.notApply)
        }
        let date: Date = transformDate(date: checkScaDTO.systemDate)
        switch accountIndicator {
        case .notApply, .notPhone:
            return UseCaseResponse.ok(GetScaAccountsStateUseCaseOkOutput.notApply)
        case .requestOtp:
            if try checkOtpAccountFilled() {
                return UseCaseResponse.ok(GetScaAccountsStateUseCaseOkOutput.notApply)
            } else {
                return UseCaseResponse.ok(GetScaAccountsStateUseCaseOkOutput.requestOtp(date: date))
            }
        case .temporaryLock:
            switch requestValues {
            case .normal:
                return UseCaseResponse.ok(GetScaAccountsStateUseCaseOkOutput.temporaryLock(date: date))
            case .force:
                return try loadSca(date: date)
            }
        }
    }
    
    private func loadSca(date: Date) throws -> UseCaseResponse<GetScaAccountsStateUseCaseOkOutput, StringErrorOutput> {
        let scaManager: BSANScaManager = provider.getBsanScaManager()
        let response: BSANResponse<CheckScaDTO> = try scaManager.loadCheckSca()
        guard response.isSuccess(), let checkScaDTO: CheckScaDTO = try response.getResponseData(), let accountIndicator: ScaAccountState =  checkScaDTO.accountIndicator else {
            return UseCaseResponse.ok(GetScaAccountsStateUseCaseOkOutput.error(date: date))
        }
        let secondDate: Date = transformDate(date: checkScaDTO.systemDate)
        switch accountIndicator {
        case .notApply, .notPhone:
            return UseCaseResponse.ok(GetScaAccountsStateUseCaseOkOutput.notApply)
        case .temporaryLock:
            return UseCaseResponse.ok(GetScaAccountsStateUseCaseOkOutput.temporaryLock(date: secondDate))
        case .requestOtp:
            return UseCaseResponse.ok(GetScaAccountsStateUseCaseOkOutput.requestOtp(date: secondDate))
        }
    }
    
    private func transformDate(date: Date?) -> Date {
        let date: Date = date ?? Date()
        return date.getDateByAdding(days: -backwardDays, ignoreHours: true)
    }
    
    private func checkOtpAccountFilled() throws -> Bool {
        let scaManager: BSANScaManager = provider.getBsanScaManager()
        let response: BSANResponse<Bool> = try scaManager.isScaOtpOkForAccounts()
        guard response.isSuccess(), let isFilled: Bool = try response.getResponseData() else {
            return false
        }
        return isFilled
    }
}

enum GetScaAccountsStateUseCaseInput {
    case normal
    case force
}

enum GetScaAccountsStateUseCaseOkOutput {
    case notApply
    case temporaryLock(date: Date)
    case requestOtp(date: Date)
    case error(date: Date)
}
