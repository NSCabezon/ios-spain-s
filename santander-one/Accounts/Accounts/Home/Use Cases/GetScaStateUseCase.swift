import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetScaStateUseCase: UseCase<GetScaStateUseCaseInput, GetScaStateUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    private let backwardDays: Int = 89
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetScaStateUseCaseInput) throws -> UseCaseResponse<GetScaStateUseCaseOkOutput, StringErrorOutput> {
        let configuration: AccountsHomeConfiguration = dependenciesResolver.resolve(for: AccountsHomeConfiguration.self)
        guard configuration.isScaForTransactionsEnabled else {
            return .ok(GetScaStateUseCaseOkOutput(scaState: .notApply))
        }
        let scaManager: BSANScaManager = provider.getBsanScaManager()
        let response: BSANResponse<CheckScaDTO> = try scaManager.checkSca()
        guard response.isSuccess(), let checkScaDTO: CheckScaDTO = try response.getResponseData(), let accountIndicator: ScaAccountState =  checkScaDTO.accountIndicator else {
            return .ok(GetScaStateUseCaseOkOutput(scaState: .notApply))
        }
        let date: Date = transformDate(date: checkScaDTO.systemDate)
        switch accountIndicator {
        case .notApply, .notPhone:
            return .ok(GetScaStateUseCaseOkOutput(scaState: .notApply))
        case .requestOtp:
            if try checkOtpAccountFilled() {
                return .ok(GetScaStateUseCaseOkOutput(scaState: .notApply))
            } else {
                return .ok(GetScaStateUseCaseOkOutput(scaState: .requestOtp(date: date)))
            }
        case .temporaryLock:
            switch requestValues {
            case .normal:
                return .ok(GetScaStateUseCaseOkOutput(scaState: .temporaryLock(date: date)))
            case .force:
                return try loadSca(date: date)
            }
        }
    }
    
    private func loadSca(date: Date) throws -> UseCaseResponse<GetScaStateUseCaseOkOutput, StringErrorOutput> {
        let scaManager: BSANScaManager = provider.getBsanScaManager()
        let response: BSANResponse<CheckScaDTO> = try scaManager.loadCheckSca()
        guard response.isSuccess(), let checkScaDTO: CheckScaDTO = try response.getResponseData(), let accountIndicator: ScaAccountState =  checkScaDTO.accountIndicator else {
            return .ok(GetScaStateUseCaseOkOutput(scaState: .error(date: date)))
        }
        switch accountIndicator {
        case .notApply, .notPhone:
            return .ok(GetScaStateUseCaseOkOutput(scaState: .notApply))
        case .temporaryLock:
            return .ok(GetScaStateUseCaseOkOutput(scaState: .temporaryLock(date: date)))
        case .requestOtp:
            return .ok(GetScaStateUseCaseOkOutput(scaState: .requestOtp(date: date)))
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

enum GetScaStateUseCaseInput {
    case normal
    case force
}

struct GetScaStateUseCaseOkOutput {
    let scaState: ScaState
}
