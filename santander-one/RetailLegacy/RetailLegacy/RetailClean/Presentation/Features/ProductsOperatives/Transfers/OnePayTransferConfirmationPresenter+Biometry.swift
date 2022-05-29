//
//  OnePayTransferConfirmationPresenter+Biometry.swift
//  RetailLegacy
//

import Foundation
import CoreFoundationLib

extension OnePayTransferConfirmationPresenter: SanKeyValidatorDelegate {
    public func success(deviceToken: String, footprint: String, onCompletion: @escaping (Bool, String?) -> Void) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let type = parameter.type,
              let originAccount = parameter.productSelected,
              let amount = parameter.amount,
              let beneficiary = parameter.name,
              let iban = parameter.iban,
              let time = parameter.time,
              let subType = parameter.subType
        else {
            onCompletion(false, nil)
            return
        }
        guard let onePayOperative = container?.operative as? OnePayTransferOperative else {
            onCompletion(false, nil)
            return
        }
        parameter.footprint = footprint
        parameter.deviceToken = deviceToken
        parameter.userPreffersBiometry = true
        container?.saveParameter(parameter: parameter)
        super.validateSanKeyTransfer { isSucces in
            if isSucces {
                onePayOperative.performNationalSignature(for: self.genericErrorHandler) { isSuccess, error in
                    if isSuccess {
                        onePayOperative.performNationalOTP(for: self,
                                                           validation: nil,
                                                           otpCode: nil) { successOutput, errorOutput in
                            if successOutput {
                                onCompletion(true, nil)
                            } else {
                                onCompletion(false, errorOutput?.localizedDescription)
                            }
                        }
                    } else {
                        onCompletion(false, error?.localizedDescription)
                    }
                }
            } else {
                onCompletion(false, nil)
            }
        }
    }

    public func continueSignProcess() {
        didSelectContinue()
    }

    public func biometryDidSuccessfullyDisappear() {
        container?.rebuildSteps()
        container?.stepFinished(presenter: self)
    }

    public func biometryDidDisappear(withError error: String?) {
        self.view.showDialog(
            withDependenciesResolver: self.dependenciesResolver,
            description: error ?? ""
        )
    }

    public func getScreen() -> String {
        TrackerPagePrivate.NationalTransferConfirmationPage().page
    }
}

extension OnePayTransferConfirmationPresenter: GenericOtpDelegate {
    var operativeStepPresenter: OperativeStepPresenterProtocol {
        return self
    }
    
    func hideOtpLoading(completion: @escaping () -> Void) {
        hideAllLoadings(completion: completion)
    }
    
    func updateOtpLoading(text: LoadingText) {
        if let loading = getLoading() {
            loading.setText(text: text)
        } else {
            LoadingCreator.setLoadingText(loadingText: text)
        }
    }
    
    func showOtpError(keyDesc: String?, completion: @escaping () -> Void) {
        showError(keyDesc: keyDesc, completion: completion)
    }
    
    var errorOtpHandler: GenericPresenterErrorHandler {
        return self.genericErrorHandler
    }
}
