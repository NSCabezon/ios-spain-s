import Foundation
import CoreFoundationLib
import Transfer

class TransferAccountSelectorPresenter<T: SelectorTransferOperativeData, Navigator>: OperativeStepPresenter<OnePayAccountSelectorViewController, Navigator, OnePayAccountSelectorPresenterProtocol> {
    weak var selectorView: TransferAccountSelectorViewProtocol?
    var accounts: [TransferAccountItemViewModel] = []
    var accountNotVisibles: [TransferAccountItemViewModel] = []
    var productSelected: Account? {
        let parameter: T = containerParameter()
        return parameter.account
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        let parameter: T = containerParameter()
        guard parameter.account == nil else { onSuccess(false); return }
        if parameter.isBackToOriginEnabled {
            guard let container = container else { return }
            container.operative.performPreSetup(
                for: self,
                container: container,
                completion: { [weak self] (_, _) in
                    guard let strongSelf = self, let dependenciesResolver = self?.dependenciesResolver else { return
                    }
                    strongSelf.accounts = parameter.list.map { TransferAccountItemViewModel(account: $0.accountEntity, dependenciesResolver: dependenciesResolver) }
                    if let notVisibles = parameter.listNotVisibles {
                        strongSelf.accountNotVisibles = notVisibles.map { TransferAccountItemViewModel(account: $0.accountEntity, dependenciesResolver: dependenciesResolver) }
                    }
                    onSuccess(true)
                }
            )
        } else {
            self.accounts = parameter.list.map { TransferAccountItemViewModel(account: $0.accountEntity, dependenciesResolver: self.dependenciesResolver) }
            if let notVisibles = parameter.listNotVisibles {
                self.accountNotVisibles = notVisibles.map { TransferAccountItemViewModel(account: $0.accountEntity, dependenciesResolver: self.dependenciesResolver) }
            }
            onSuccess(true)
        }
    }
}

extension TransferAccountSelectorPresenter: OnePayAccountSelectorPresenterProtocol {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies.useCaseProvider.dependenciesResolver
    }
    
    func didTapBack() {
        container?.operativeContainerNavigator.back()
    }
    
    func didTapFaqs() {
        let parameter: T = containerParameter()
        let faqModel = parameter.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
        } ?? []
        self.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.TransferFaqs().page, extraParameters: [:])
        self.view.showFaqs(faqModel)
    }
    
    func didTapClose() {
        container?.cancelTouched(completion: nil)
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question":question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: .transfersFaqsAnalytics, object: nil, userInfo: ["parameters": dic])
    }
}

extension TransferAccountSelectorPresenter: TransferAccountSelectorPresenterProtocol {
    func viewDidAppear() {
        self.selectorView?.showAccounts(accountVisibles: self.accounts, accountNotVisibles: self.accountNotVisibles)
    }
    
    func didSelectAccount(_ viewModel: TransferAccountItemViewModel) {
        let parameter: T = containerParameter()
        parameter.setAccount(viewModel.account)
        guard let container = container else { return }
        container.saveParameter(parameter: parameter)
        self.startOperativeLoading {
            container.operative.performSetup(
                for: self,
                container: container,
                success: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.hideOperativeLoading {
                        container.stepFinished(presenter: strongSelf)
                    }
                }
            )
        }
    }
}

extension TransferAccountSelectorPresenter: OperativeLauncherPresentationDelegate {
    func startOperativeLoading(completion: @escaping () -> Void) {
        let type = LoadingViewType.onScreen(controller: view, completion: completion)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        hideLoading(completion: completion)
    }
    
    func showOperativeAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, source: view)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: nil, completion: completion)
    }
    
    var errorOperativeHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
}
