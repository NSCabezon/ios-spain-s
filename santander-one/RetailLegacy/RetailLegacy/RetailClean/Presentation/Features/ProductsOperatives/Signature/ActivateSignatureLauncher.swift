import CoreFoundationLib
import Operative

protocol ActivateSignatureLauncher: class {
    var useCaseProvider: UseCaseProvider { get }
    var useCaseHandler: UseCaseHandler { get }
    var genericErrorHandler: GenericPresenterErrorHandler { get }
    var dependencies: PresentationComponent { get }
    var activateSignatureLauncherNavigator: OperativesNavigatorProtocol { get }
    
    func showError(keyDesc: String?)
}

extension ActivateSignatureLauncher {
    func goToActivateSignature(operativeConfig: OperativeConfig? = nil) {
        if let operativeConfig = operativeConfig {
            navigateToOperative(operativeConfig: operativeConfig)
        } else {
            getOperativeConfig()
        }
    }
    
    private func getOperativeConfig() {
        let useCase = useCaseProvider.setupSignatureUseCase(input: SetupSignatureUseCaseInput(settingOption: .activateSignature))
        
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] result in
            self?.navigateToOperative(operativeConfig: result.operativeConfig)
        }, onError: { [weak self] error in
            self?.showError(keyDesc: error?.getErrorDesc())
        })
    }
    
    private func navigateToOperative(operativeConfig: OperativeConfig) {
        let operative = ActivateSignOperative(dependencies: dependencies)
        var parameters: [OperativeParameter] = [operativeConfig]
        parameters.append(SignaturePurpose.signatureActivation)
        activateSignatureLauncherNavigator.goToOperative(operative,
                                                         withParameters: parameters,
                                                         dependencies: dependencies)
    }
}
