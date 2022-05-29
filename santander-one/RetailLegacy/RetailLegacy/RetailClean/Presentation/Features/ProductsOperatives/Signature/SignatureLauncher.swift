import CoreFoundationLib
import Operative

protocol SignatureLauncher: class {
    var useCaseProvider: UseCaseProvider { get }
    var dependencies: PresentationComponent { get }
    var signatureLauncherNavigator: OperativesNavigatorProtocol { get }
    func showError(keyDesc: String?)
    func goToSignature()
}

extension SignatureLauncher {   
    func goToSignature() {
        let useCase = self.useCaseProvider.getSignatureOperativeConfigurationUseCase()
        MainThreadUseCaseWrapper(with: useCase, errorHandler: nil, onSuccess: { [weak self] response in
            guard let self = self else { return }
            let operative: Operative
            var parameters: [OperativeParameter] = [response.operativeConfig]
            if response.isSignatureActivationPending {
                operative = ActivateSignOperative(dependencies: self.dependencies)
                parameters.append(SignaturePurpose.signatureActivation)
            } else {
                operative = ChangeSignOperative(dependencies: self.dependencies)
            }
            self.signatureLauncherNavigator.goToOperative(operative, withParameters: parameters, dependencies: self.dependencies)
        }, onError: { [weak self] error in
            self?.showError(keyDesc: error?.getErrorDesc())
        })
    }
}
