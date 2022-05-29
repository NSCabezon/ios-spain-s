import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class FirstInstallationSuperUseCase<Delegate: SuperUseCaseDelegate>: SuperUseCase<Delegate, GenericPresenterErrorHandler> {
    
    override func setupUseCases() {
        add(useCaseProvider.getIsFirstInstallationUseCase(), isMandatory: false, onSuccess: executeFirstInstallationUseCases)
    }
    
    private func executeFirstInstallationUseCases(_ response: IsFirstInstallationUseCaseOkOutput) {
        guard response.isFirstInstallation else { return }
        add(useCaseProvider.getRemoveTokenPushUseCase(), isMandatory: false)
        add(useCaseProvider.getSaveFirstInstallationUseCase(), isMandatory: false)
    }
}
