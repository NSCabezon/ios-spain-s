import Foundation
import CoreFoundationLib

protocol SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig { get set }
}

class SetupUseCase<Request, Result: SetupUseCaseOkOutputProtocol, Err: StringErrorOutput>: UseCase<Request, Result, Err> {
    internal var appConfigRepository: AppConfigRepository
    
    init(appConfigRepository: AppConfigRepository) {
        self.appConfigRepository = appConfigRepository
    }
    
    func getOperativeConfig() -> UseCaseResponse<SetupUseCaseOKOutput, SetupUseCaseErrorOutput> {
        let operativeConfig = OperativeConfig(signatureSupportPhone: appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigSignatureSupportPhone), otpSupportPhone: appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigOTPSupportPhone), cesSupportPhone: appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigCesSupportPhone), consultiveUserPhone: appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigConsultiveUserSupportPhone), loanAmortizationSupportPhone: appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigloanAmortizationSupportPhone))
        
        return UseCaseResponse.ok(SetupUseCaseOKOutput(operativeConfig: operativeConfig))
    }
}

struct SetupUseCaseOKOutput {
    var operativeConfig: OperativeConfig
}

class SetupUseCaseErrorOutput: StringErrorOutput {}
