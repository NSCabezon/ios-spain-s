import Foundation
import CoreFoundationLib

protocol AccountSelectorPresenterProtocol: Presenter {
    var selectorView: AccountSelectorViewProtocol? { get set }
    var progressBarBackgroundStyle: ProductSelectionProgressStyle { get }
    func selected(viewModel: OldSelectableAccountViewModel)
    func didTapFaqs()
    func didTapClose()
    func didTapBack()
    func trackFaqEvent(_ question: String, url: URL?)
}

class AccountSelectorPresenter: OperativeStepPresenter<AccountSelectorViewController, VoidNavigator, AccountSelectorPresenterProtocol> {
    
    weak var selectorView: AccountSelectorViewProtocol?
    private var accountVisibles: [OldSelectableAccountViewModel] = []
    private var accountNotVisibles: [OldSelectableAccountViewModel] = []

    override var screenId: String? {
        return TrackerPagePrivate.BillAndTaxesPayBill().page
    }
    
    override func loadViewData() {
        super.loadViewData()
        self.getInfo()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_originAccount")
        let operativeData: BillAndTaxesOperativeData? = container?.provideParameter()
        guard let type = operativeData?.typeOperative else { return }
        switch type {
        case .bills:
            view.localizedSubTitleKey = "toolbar_title_payReceipts"
        case .taxes:
            view.localizedSubTitleKey = "toolbar_title_taxPayment"
        }
    }

    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard parameter.list.count > 0 else {
            return onSuccess(false)
        }
        self.accountVisibles = parameter.list.map { OldSelectableAccountViewModel(account: $0) }
        if let notVisibles = parameter.listNotVisible {
            self.accountNotVisibles = notVisibles.map { OldSelectableAccountViewModel(account: $0) }
        }
        onSuccess(true)
    }
}

private extension AccountSelectorPresenter {
    func getInfo() {
        self.selectorView?.showAccounts(accountVisibles: self.accountVisibles, accountNotVisibles: self.accountNotVisibles)
    }
}

extension AccountSelectorPresenter: AccountSelectorPresenterProtocol {
    var progressBarBackgroundStyle: ProductSelectionProgressStyle {
        return .uiBackground
    }
    
    func selected(viewModel: OldSelectableAccountViewModel) {
        guard let container = self.container else { return }
        self.container?.operative.performSetup(for: self, container: container) { [weak self] in
            guard let operativeData: BillAndTaxesOperativeData = self?.containerParameter(), let self = self else { return }
            operativeData.productSelected = viewModel.account
            self.container?.saveParameter(parameter: operativeData)
            self.container?.stepFinished(presenter: self)
        }
    }
    
    func didTapFaqs() {
        let operativeData: BillAndTaxesOperativeData = containerParameter()
        let faqs = operativeData.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
            } ?? []
        self.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.BillAndTaxesFaq().page, extraParameters: [:])
        self.view.showFaqs(faqs)
    }
    
    func didTapClose() {
        container?.cancelTouched(completion: nil)
    }
    
    func didTapBack() {
        container?.operativeContainerNavigator.back()
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question":question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: .billsFaqsAnalytics, object: nil, userInfo: ["parameters": dic])
    }
}

extension AccountSelectorPresenter: OperativeLauncherPresentationDelegate {
    func startOperativeLoading(completion: @escaping () -> Void) {
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: view, completion: completion)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        hideLoading(completion: completion)
    }
    
    func showOperativeAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, source: view, shouldTriggerHaptic: true)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: nil, completion: completion)
    }
    
    var errorOperativeHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
}
