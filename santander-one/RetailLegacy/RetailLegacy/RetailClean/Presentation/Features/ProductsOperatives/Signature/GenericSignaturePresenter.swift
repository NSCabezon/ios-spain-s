import CoreFoundationLib
import Operative
import CorePushNotificationsService
import CoreDomain

class GenericSignaturePresenter<S: SignatureParamater>: OperativeStepPresenter<GenericSignatureViewController, ProductHomeNavigatorProtocol, GenericSignaturePresenterProtocol> {
    private var _signature: S?
    
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
        _signature = containerParameter()
        dependencies.navigatorProvider.presenterProvider.dependenciesEngine.resolve(forOptionalType: PushNotificationsExecutorProtocol.self)?.removeScheduledNotifications(forType: .otp)
    }
}

extension GenericSignaturePresenter: Presenter {}

extension GenericSignaturePresenter: GenericSignaturePresenterProtocol {
    func didTapClose() {
        container?.cancelTouched(completion: nil)
    }
    
    func didTapBack() {
        container?.operativeContainerNavigator.back()
    }
    
    var navigationBarTitle: String? {
        if let optionalNavigationTitle = container?.operative.signatureNavigationTitle {
            return optionalNavigationTitle
        }
        return nil
    }
    
    var styledTitle: LocalizedStylableText {
        guard let container = container else {
            fatalError()
        }
        return container.operative.signatureTitle
    }
    
    var signature: SignatureRepresentable? {
        return _signature
    }
    
    var showsHelpButton: Bool {
        guard let faqs = self.container?.operative.infoHelpButtonFaqs else { return false }
        return faqs.count > 0
    }
    
    func validPositionsArray(_ values: SignatureRepresentable) {
        guard let container = container, let filled = values as? S else {
            return
        }
        let signatureFilled = SignatureFilled<S>(signature: filled)
        container.saveParameter(parameter: signatureFilled)
        self.view.endEditing(true)
        LoadingCreator.showGlobalLoading(loadingText: LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))) {
            self.view.activateInteractionUser(false)
            container.operative.performSignature(for: self.genericErrorHandler) { [weak self] success, error in
                guard let thisPresenter = self else {
                    return
                }
                guard success else {
                    LoadingCreator.hideGlobalLoading(completion: {
                        self?.view.activateInteractionUser(true)
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
                    self?.view.activateInteractionUser(true)
                }
            }
        }
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
                self.view.resetNumberTextFields()
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
    
    func validateCharacter(_ text: String) -> Bool {
        return text.range(of: alphaNumRegex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func didSelectHelp() {
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
    
    func didSelectHelpNavBar() {
        guard let faqs = self.faqs else { return }
        self.view.showFaqs(faqs)
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question":question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: .transfersFaqsAnalytics, object: nil, userInfo: ["parameters": dic])
        NotificationCenter.default.post(name: .billsFaqsAnalytics, object: nil, userInfo: ["parameters": dic])
    }
}

private extension GenericSignaturePresenter {
    var faqs: [FaqsItemViewModel]? {
        guard let faqs = self.container?.operative.infoHelpButtonFaqs, faqs.count > 0 else { return nil }
        return faqs
    }
}
