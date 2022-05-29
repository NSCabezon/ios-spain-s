import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetScaLoginStateUseCase: UseCase<Void, GetScaLoginStateUseCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetScaLoginStateUseCaseOkOutput, StringErrorOutput> {
        let appConfigCheckSca = appConfigRepository.getBool("enableSCALogin") ?? false
        let appConfigEnableSCAAccountTransactions = appConfigRepository.getBool("enableSCAAccountTransactions") ?? false
        guard appConfigCheckSca || appConfigEnableSCAAccountTransactions else {
            return UseCaseResponse.ok(GetScaLoginStateUseCaseOkOutput.notApply)
        }
        let scaManager: BSANScaManager = managersProvider.getBsanScaManager()
        let response: BSANResponse<CheckScaDTO> = try scaManager.checkSca()
        guard appConfigCheckSca else {
            return UseCaseResponse.ok(GetScaLoginStateUseCaseOkOutput.notApply)
        }
        guard response.isSuccess(), let checkScaDTO: CheckScaDTO = try response.getResponseData(), let loginIndicator: ScaLoginState =  checkScaDTO.loginIndicator else {
            return UseCaseResponse.ok(GetScaLoginStateUseCaseOkOutput.notApply)
        }
        switch loginIndicator {
        case .notApply, .notPhone:
            return UseCaseResponse.ok(GetScaLoginStateUseCaseOkOutput.notApply)
        case .temporaryLock:
            return UseCaseResponse.ok(GetScaLoginStateUseCaseOkOutput.temporaryLock)
        case .requestOtp:
            if try checkOtpLoginAsked() {
                 return UseCaseResponse.ok(GetScaLoginStateUseCaseOkOutput.notApply)
            } else {
                 return UseCaseResponse.ok(GetScaLoginStateUseCaseOkOutput.requestOtp)
            }
        case .requestOtpFirstTime:
            if try checkOtpLoginAsked() {
                return UseCaseResponse.ok(GetScaLoginStateUseCaseOkOutput.notApply)
            } else {
                return UseCaseResponse.ok(GetScaLoginStateUseCaseOkOutput.requestOtpFirstTime)
            }
        }
    }
    
    private func checkOtpLoginAsked() throws -> Bool {
        let scaManager: BSANScaManager = managersProvider.getBsanScaManager()
        let response: BSANResponse<Bool> = try scaManager.isScaOtpAskedForLogin()
        guard response.isSuccess(), let isAsked: Bool = try response.getResponseData() else {
            return false
        }
        return isAsked
    }
}

extension GetScaLoginStateUseCase: RepositoriesResolvable {}

enum GetScaLoginStateUseCaseOkOutput {
    case notApply
    case temporaryLock
    case requestOtp
    case requestOtpFirstTime
}
