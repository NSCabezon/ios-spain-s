//
//  LisboaSignaturePresenter.swift
//  RetailClean
//
//  Created by Jose Carlos Estela Anguita on 02/01/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import Operative
import CoreFoundationLib
import CorePushNotificationsService
import CoreDomain

protocol LisboaSignaturePresenterProtocol: OperativeStepPresenterProtocol, SignaturePresenterProtocol {
    var showsHelpButton: Bool { get }
    func didTapBack()
    func didTapClose()
    var navigationBarTitle: String? { get }
}

class LisboaSignaturePresenter<S: SignatureParamater>: OperativeStepPresenter<LisboaSignatureViewController, ProductHomeNavigatorProtocol, LisboaSignaturePresenterProtocol> {
    
    private lazy var _signature: S = {
        containerParameter()
    }()
    
    override var isBackable: Bool {
        return false
    }
    
    override var screenId: String? {
        return container?.operative.screenIdSignature
    }
    
    override func getTrackParameters() -> [String: String]? {
        return container?.operative.getTrackParametersSignature()
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.setupViews()
        dependencies.navigatorProvider.presenterProvider.dependenciesEngine.resolve(forOptionalType: PushNotificationsExecutorProtocol.self)?.removeScheduledNotifications(forType: .otp)
    }
    
    func handle(error: GenericErrorSignatureErrorOutput?) {
        container?.operative.trackErrorEvent(page: screenId, error: error?.getErrorDesc(), code: error?.errorCode)
        guard let container = container, let errorType = error else { return }
        var acceptAction = {}
        var keyTitle = ""
        var errorDescKey = error?.getErrorDesc()
        let operativesConfig: OperativeConfig = container.provideParameter()
        let phoneNumber = operativesConfig.signatureSupportPhone
                
        switch errorType.signatureResult {
        case .revoked:
            keyTitle = "signing_title_popup_blocked"
            guard let isEmptyPhone = phoneNumber?.isEmpty else { return }
            if isEmptyPhone {
                errorDescKey = "signing_text_popup_blocked_withoutNumber"
            } else {
                errorDescKey = "signing_text_popup_blocked"
            }
            acceptAction = {
                if let container = self.container {
                    container.onSignatureError()
                }
            }
        case .otpUserExcepted:
            break
        case .ok:
            self.container?.stepFinished(presenter: self)
        case .invalid:
            keyTitle = "signing_title_popup_error"
            errorDescKey = "operative_error_SIGBRO_00003"
            acceptAction = {
                self.view.reset()
            }
        case .otherError:
            acceptAction = {
                if let container = self.container {
                    container.onSignatureError()
                }
            }
        }
        if [.otherError, .revoked].contains(errorType.signatureResult) {
            self.showFatalError(keyTitle: keyTitle, keyDesc: errorDescKey, phone: phoneNumber, completion: acceptAction)
        } else {
            self.showError(keyTitle: keyTitle, keyDesc: errorDescKey, phone: phoneNumber, completion: acceptAction)
        }
    }
    
}

extension LisboaSignaturePresenter: Presenter {
    
}

extension LisboaSignaturePresenter: LisboaSignaturePresenterProtocol {
    var operative: OperativeSignatureCapable? {
        return nil
    }
    
    var signature: SignatureRepresentable {
        return _signature
    }
    
    var showsHelpButton: Bool {
        guard let faqs = self.container?.operative.infoHelpButtonFaqs else { return false }
        return faqs.count > 0
    }
    
    // Necessary because of the LisboaSignaturePresenterProtocol depends on SignaturePresenterProtocol and is working in Operative Module
    func viewDidLoad() {
        let purp: SignaturePurpose? = container?.provideParameterOptional()
        view.setPurpose(purp ?? .general)
    }
    
    func validateCharacters(of text: String) -> Bool {
        return text.range(of: alphaNumRegex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func didSelectAccept(withValues values: [String]) {
        guard let container = container else {
            return
        }
        _signature.values = values
        let signatureFilled = SignatureFilled<S>(signature: _signature)
        container.saveParameter(parameter: signatureFilled)
                
        LoadingCreator.showGlobalLoading(loadingText: LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))) {
                container.operative.performSignature(for: self.genericErrorHandler) { [weak self] success, error in
                    guard let thisPresenter = self else {
                        return
                    }
                    guard success else {
                        LoadingCreator.hideGlobalLoading(completion: {
                            thisPresenter.handle(error: error)
                        })
                        return
                    }
                    let signatureCompletion: () -> Void = {
                        thisPresenter.container?.stepFinished(presenter: thisPresenter)
                    }
                    if container.needsOTP {
                        signatureCompletion()
                    } else {
                        LoadingCreator.hideGlobalLoading(completion: signatureCompletion)
                    }
                    
                }
            }
    }
    
    func didSelectRememberSignature() {
        HapticTrigger.alert()
        navigator.showListDialog(
            title: localized(key: "signing_title_popup_rememberInfo"),
            items: [
                .styledText("signing_text_popup_rememberInfoSigning", LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14))),
                .listItem("signing_text_popup_rememberInfoForward", margin: .zero()),
                .listItem("signing_text_popup_rememberInfoRequest", margin: .zero()),
                .listItem("signing_text_popup_rememberInfoVisitOffice", margin: .zero())
            ],
            type: .withButton(localized(key: "generic_button_understand"))
        )
    }
    
    func didSelectHelp() {
        guard let faqs = self.faqs else { return }
        self.view.showFaqs(faqs)
    }
    
    func didTapBack() {
        container?.operativeContainerNavigator.back()
    }
    
    func didTapClose() {
        closeButtonTouched()
    }
    
    var navigationBarTitle: String? {
        if let optionalNavigationTitle = container?.operative.signatureNavigationTitle {
            return optionalNavigationTitle
        }
        return nil
    }
}

private extension LisboaSignaturePresenter {
    var faqs: [FaqsItemViewModel]? {
        guard let faqs = self.container?.operative.infoHelpButtonFaqs, faqs.count > 0 else { return nil }
        return faqs
    }
}
