import Foundation
import CoreFoundationLib
import BiometryValidator

extension BizumConfirmationPresenter: BiometryValidatorModuleCoordinatorDelegate {
    func success(deviceToken: String, footprint: String, onCompletion: @escaping (Bool, String?) -> Void) {
        performSignaturePositionUseCase { [weak self] in
            guard let self = self else { return }
            self.validateBiometryTransferStateOTP?.execute(
                deviceToken: deviceToken,
                footprint: footprint) { [weak self] (isSuccess, error) in
                guard let self = self else { return }
                self.operativeData?.isBiometricEnable = true
                self.container?.save(self.operativeData)
                onCompletion(isSuccess, error)
            }
        }
    }

    func continueSignProcess() {
        self.view?.showLoading()
        performSignaturePositionUseCase { [weak self] in
            guard let self = self else { return }
            Async.main {
                self.view?.dismissLoading(completion: {
                    self.operativeData?.isBiometricEnable = false
                    self.container?.save(self.operativeData)
                    self.container?.rebuildSteps()
                    self.container?.stepFinished(presenter: self)
                })
            }
        }
    }

    func biometryDidSuccessfullyDisappear() {
        self.container?.rebuildSteps()
        self.container?.stepFinished(presenter: self)
    }

    func biometryDidDisappear(withError error: String?) {
        self.view?.showDialog(
            withDependenciesResolver: self.dependenciesResolver,
            description: error ?? ""
        )
    }

    func getScreen() -> String {
        "bizum"
    }
}
