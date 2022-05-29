import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public struct OperativeConfig {
    public var signatureSupportPhone: String?
    public var otpSupportPhone: String?
    public var cesSupportPhone: String?
    public var consultiveUserPhone: String?
    public var loanAmortizationSupportPhone: String?
    
    struct Constants {
        static let appConfigSignatureSupportPhone = "signatureSupportPhone"
        static let appConfigOTPSupportPhone = "otpSupportPhone"
        static let appConfigCesSupportPhone = "cesSupportPhone"
        static let appConfigloanAmortizationSupportPhone = "loanAmortizationSupportPhone"
        static let appConfigConsultiveUserSupportPhone = "consultiveUserSupportPhone"
    }

    public init(signatureSupportPhone: String?, otpSupportPhone: String?, cesSupportPhone: String?, consultiveUserPhone: String?, loanAmortizationSupportPhone: String?) {
        self.signatureSupportPhone = signatureSupportPhone
        self.otpSupportPhone = otpSupportPhone
        self.cesSupportPhone = cesSupportPhone
        self.consultiveUserPhone = consultiveUserPhone
        self.loanAmortizationSupportPhone = loanAmortizationSupportPhone
    }
}

public class OperativeSetupUseCase: UseCase<Void, OperativeSetupUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<OperativeSetupUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let operativeConfig = OperativeConfig(
            signatureSupportPhone: appConfigRepository.getString(OperativeConfig.Constants.appConfigSignatureSupportPhone),
            otpSupportPhone: appConfigRepository.getString(OperativeConfig.Constants.appConfigOTPSupportPhone),
            cesSupportPhone: appConfigRepository.getString(OperativeConfig.Constants.appConfigCesSupportPhone),
            consultiveUserPhone: appConfigRepository.getString(OperativeConfig.Constants.appConfigConsultiveUserSupportPhone),
            loanAmortizationSupportPhone: appConfigRepository.getString(OperativeConfig.Constants.appConfigloanAmortizationSupportPhone)
        )
        return UseCaseResponse.ok(OperativeSetupUseCaseOkOutput(config: operativeConfig))
    }
}

public struct OperativeSetupUseCaseOkOutput {
    public let config: OperativeConfig
}
