//
//  SignaturePresenter.swift
//  Operative
//
//  Created by Jose Carlos Estela Anguita on 30/12/2019.
//

import Foundation
import CoreFoundationLib
import UI
import CoreDomain

public protocol SignaturePresenterProtocol: AnyObject {
    var signature: SignatureRepresentable { get }
    var showsHelpButton: Bool { get }
    var operative: OperativeSignatureCapable? { get }
    func validateCharacters(of text: String) -> Bool
    func didSelectAccept(withValues values: [String])
    func didSelectRememberSignature()
    func viewDidLoad()
    func didTapClose()
    func didTapBack()
    func didSelectHelp()
    func trackFaqEvent(_ question: String, url: URL?)
}

public extension SignaturePresenterProtocol {
    func trackFaqEvent(_ question: String, url: URL?) {}
}

/// This protocol is needed because we have the SignaturePresenterProtocol in use in the Target Application
public protocol InternalSignaturePresenterProtocol: OperativeStepPresenterProtocol, SignaturePresenterProtocol {
    var view: InternalSignatureViewProtocol? { get set }
}

private struct Constans {
    static let alphaNumRegex = "^[a-zA-Z0-9]+$"
}

public enum SignatureDialogType {
    case generic(dependenciesResolver: DependenciesResolver)
    case revoked(phoneNumber: String?, action: (() -> Void)?, gpAction: (() -> Void)?)
    case otpUserExcepted(error: GenericErrorSignatureErrorOutput, phoneNumber: String?, stringLoader: StringLoader)
    case invalid
    case otherError(error: GenericErrorSignatureErrorOutput, phoneNumber: String?, action: (() -> Void)?, stringLoader: StringLoader)
}

public final class SignaturePresenter {
    
    public weak var view: InternalSignatureViewProtocol?
    private var privateSignature: SignatureRepresentable {
        guard
            let container = self.container,
            let signature: SignatureRepresentable = container.get()
        else {
            fatalError()
        }
        return signature
    }
    public var number: Int = 0
    public var container: OperativeContainerProtocol?
    public var isBackButtonEnabled: Bool = false
    public var isCancelButtonEnabled: Bool = false
    private let dependenciesResolver: DependenciesResolver
    private var faqsCapableOperative: OperativeFaqsCapable? {
        self.container?.operative as? OperativeFaqsCapable
    }
    
    private var signaturePurpose: SignaturePurpose? {
        return container?.getOptional()
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension SignaturePresenter: OperativeStepPresenterProtocol {
    
    public var shouldShowProgressBar: Bool {
        guard let operative = self.container?.operative as? OperativeSignatureCapable else { return false }
        return operative.isProgressBarEnabled
    }
    
    public func validateCharacters(of text: String) -> Bool {
        return text.range(of: Constans.alphaNumRegex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    public func didSelectAccept(withValues values: [String]) {
        self.view?.showLoading()
        guard let view = self.view, let signatureCapable = self.container?.operative as? OperativeSignatureCapable else {
            self.view?.dismissLoading()
            return
        }
        guard var signature: SignatureRepresentable = self.container?.get() else {
            self.view?.dismissLoading()
            return
        }
        signature.values = values
        self.container?.save(signature)
        signatureCapable.performSignature(for: view) { [weak self] success, error in
            view.dismissLoading {
                guard let self = self else { return }
                guard success else {
                    self.handle(error: error)
                    return
                }
                self.container?.stepFinished(presenter: self)
            }
        }
    }
    
    public func didSelectRememberSignature() {
        self.view?.showDialog(
            title: "signing_title_popup_rememberInfo",
            items: [
                .text("signing_text_popup_rememberInfoSigning"),
                .listItem("signing_text_popup_rememberInfoForward"),
                .listItem("signing_text_popup_rememberInfoRequest"),
                .listItem("signing_text_popup_rememberInfoVisitOffice")
            ],
            action: Dialog.Action(title: "generic_button_understand", action: { }),
            isCloseOptionAvailable: false
        )
    }
}

extension SignaturePresenter: InternalSignaturePresenterProtocol {
    public var showsHelpButton: Bool {
        return self.container?.operative as? OperativeFaqsCapable != nil
    }
    
    public func didTapClose() {
        self.container?.close()
    }
    
    public func didTapBack() {
        self.container?.back()
    }
    
    public var signature: SignatureRepresentable {
        return self.privateSignature
    }

    public func viewDidLoad() {
        view?.setPurpose(self.signaturePurpose ?? .general)
        if let trackerCapable = self.container?.operative as? OperativeTrackerCapable & OperativeSignatureTrackerCapable & Operative {
            let screenIdSignature = trackerCapable.screenIdSignature
            trackerCapable.trackScreen(screenId: screenIdSignature)
        }
        if let navigationTitleCapable = self.container?.operative as? OperativeSignatureNavigationCapable {
            view?.setNavigationBuilderTitle(navigationTitleCapable.signatureNavigationTitle)
        } else {
            view?.setNavigationBuilderTitle(nil)
        }
    }
    
    public func didSelectHelp() {
        guard let faqsCapable = faqsCapableOperative,
            let faqs = faqsCapable.infoHelpButtonFaqs
            else { return }
        self.view?.showFaqs(faqs)
    }
    
    public var operative: OperativeSignatureCapable? {
        return self.container?.operative as? OperativeSignatureCapable
    }
    
    public func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question": question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: NSNotification.Name("billsFaqsAnalytics"), object: nil, userInfo: ["parameters": dic])
    }
}

extension SignaturePresenter {
    public var isBackable: Bool {
        return false
    }
}

private extension SignaturePresenter {
    func handle(error: GenericErrorSignatureErrorOutput?) {
        guard let container = container, let errorType = error else {
            self.view?.showDialogForType(.generic(dependenciesResolver: dependenciesResolver))
            return
        }
        let trackerCapable = container.operative as? OperativeTrackerCapable & OperativeSignatureTrackerCapable & Operative
        trackerCapable?.trackErrorEvent(page: trackerCapable?.screenIdSignature, error: errorType.getErrorDesc(), code: errorType.errorCode)
        
        guard let operativesConfig: OperativeConfig = container.get(),
              let phoneNumber = operativesConfig.signatureSupportPhone else {
            return
        }
        
        switch errorType.signatureResult {
        case .revoked:
            self.view?.showDialogForType(.revoked(phoneNumber: phoneNumber,
                                                  action: { self.container?.goToFirstOperativeStep() },
                                                  gpAction: { self.container?.dismissOperative() } ))
        case .otpUserExcepted:
            self.view?.showDialogForType(.otpUserExcepted(error: errorType,
                                                          phoneNumber: phoneNumber,
                                                          stringLoader: self.dependenciesResolver.resolve(for: StringLoader.self)))
        case .ok:
            self.container?.stepFinished(presenter: self)
        case .invalid:
            self.view?.showDialogForType(.invalid)
        case .otherError:
            self.view?.showDialogForType(.otherError(error: errorType,
                                                     phoneNumber: phoneNumber,
                                                     action: { self.container?.goToFirstOperativeStep() },
                                                     stringLoader: self.dependenciesResolver.resolve(for: StringLoader.self)))
        case .unknown:
            break
        }
    }
}
