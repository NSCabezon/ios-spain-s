import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetPersonalAreaOptionsUseCase: UseCase<Void, GetPersonalAreaOptionsUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPersonalAreaOptionsUseCaseOkOutput, StringErrorOutput> {
        
        let signatureInfo = try provider.getBsanSignatureManager().getCMCSignature()
        guard signatureInfo.isSuccess(), let data = try signatureInfo.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(try signatureInfo.getErrorMessage()))
        }
        var result = [(SettingSection, [SettingOption])]()
        result.append((.setup, [.customizeApp, .frequentOperative, .language, .appInfo, .permissions]))
        result.append((.yourData, [.contactData, .income, .management]))
        
        let signatureData = SignatureData(signatureDataDTO: data.signatureDataDTO)
        
        if signatureData.isSignatureActivationPending() {
            result.append((.security, [.touchID, .widgetAccess, .activateSignature, .otpPush, .user]))
        } else {
            result.append((.security, [.touchID, .widgetAccess, .changeSignature, .otpPush, .user]))
        }
        
        result.append((.fineTune, [.notifications, .favoriteRecipients]))
        result.append((.extra, [.pullOffer]))
        let response = GetPersonalAreaOptionsUseCaseOkOutput(sections: result)
        
        return UseCaseResponse.ok(response)
    }
}

struct GetPersonalAreaOptionsUseCaseOkOutput {
    let sections: [(SettingSection, [SettingOption])]
}
