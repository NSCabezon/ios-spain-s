import CoreFoundationLib
import SANLegacyLibrary

class GetCMCAndSupportPhoneUseCase: UseCase<Void, GetCMCAndSupportPhoneUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    
    init(provider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = provider
        self.appConfigRepository = appConfigRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCMCAndSupportPhoneUseCaseOkOutput, StringErrorOutput> {
        let response = try provider.getBsanSignatureManager().getCMCSignature()
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage()))
        }
        let phone: String? = appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigConsultiveUserSupportPhone)
        return UseCaseResponse.ok(GetCMCAndSupportPhoneUseCaseOkOutput(isConsultiveUser: isConsultiveUser(signatureStatusInfo: data), phone: phone))
    }
    
    private func isConsultiveUser(signatureStatusInfo: SignStatusInfo?) -> Bool {
        guard let info = signatureStatusInfo else {
            return true
        }
        return info.signatureDataDTO.list?.first?.userOperabilityInd?.uppercased() == "C"
    }
}

struct GetCMCAndSupportPhoneUseCaseOkOutput {
    let isConsultiveUser: Bool
    let phone: String?
}
