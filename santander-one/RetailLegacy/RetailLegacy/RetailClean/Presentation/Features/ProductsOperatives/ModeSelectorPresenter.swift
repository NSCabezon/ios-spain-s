import Foundation
import CoreFoundationLib

enum ModeTypeBillsAndTaxes: String {
    case manual
    case camera
}

class ModeSelectorPresenter: OperativeStepPresenter<ModeSelectorViewController, VoidNavigator, ModeSelectorPresenterProtocol> {
    // MARK: - Overrided methods
    private var operativeData: BillAndTaxesOperativeData?
    private let operationTypeIdentifier = "modeType"
    
    override var screenId: String? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let type = parameter.typeOperative else { return nil }
        switch type {
        case .bills: return TrackerPagePrivate.BillAndTaxesPayBill().page
        case .taxes: return TrackerPagePrivate.BillAndTaxesPayTax().page
        }
    }
    
    override var shouldShowProgress: Bool {
        return true
    }
    
    override func loadViewData() {
        super.loadViewData()
        guard let container = container else {
            return
        }
        operativeData = container.provideParameter()
        guard let type = operativeData?.typeOperative else { return }
        switch type {
        case .bills:
            view.styledTitle = dependencies.stringLoader.getString("toolbar_title_payReceipts")
            view.localizedSubTitleKey = "toolbar_title_payReceipts"
        case .taxes:
            view.styledTitle = dependencies.stringLoader.getString("toolbar_title_payTaxes")
            view.localizedSubTitleKey = "toolbar_title_taxPayment"
        }
        infoObtained()
    }
    
    private func infoObtained() {
        guard let container = container else {
            return
        }
        operativeData = container.provideParameter()
        guard let account = operativeData?.productSelected else { return }
        
        let sectionHeader = StackSection()
        let header = AccountHeaderStackModel(accountAlias: account.getAlias() ?? "", accountIBAN: account.getIban()?.ibanShort() ?? "", accountAmount: account.getAmount()?.getAbsFormattedAmountUI() ?? "")
        sectionHeader.add(item: header)
        
        let recipientTitle = TitleLabelStackModel(title: dependencies.stringLoader.getString("generic_label_payMethod"), insets: Insets(left: 11, right: 10, top: 22, bottom: 6))
        sectionHeader.add(item: recipientTitle)
        
        view.dataSource.reloadSections(sections: [sectionHeader, buildOptionsSection()])
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
    }
    
    private func buildOptionsSection() -> StackSection {
        let section = StackSection()
        
        let manual = RadioWithoutOptionsData(isSelected: false, title: stringLoader.getString("paymentReceipt_label_manual"), type: ModeTypeBillsAndTaxes.manual.rawValue, accessibilityIdentifier: AccesibilityBills.BillEmittersPaymentDataView.manualMode)
        let camera = RadioWithoutOptionsData(isSelected: false, title: stringLoader.getString("paymentReceipt_label_withCamera"), type: ModeTypeBillsAndTaxes.camera.rawValue, accessibilityIdentifier: AccesibilityBills.BillEmittersPaymentDataView.cameraMode)
        
        let options: [RadioWithoutOptionsData] = [manual, camera]
        let modeSelectorRadio = RadioNotExpandableStackModel(inputIdentifier: operationTypeIdentifier, options: options, insets: Insets(left: 0, right: 0, top: 10, bottom: 0))
        section.add(item: modeSelectorRadio)
        return section
    }
}

extension ModeSelectorPresenter: ModeSelectorPresenterProtocol {
    func onContinueButtonClicked() {
        let typeIdentifier = view.dataSource.findData(identifier: operationTypeIdentifier)
        
        guard
            let operationTypeId = typeIdentifier,
            let type = ModeTypeBillsAndTaxes(rawValue: operationTypeId) else {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "generic_error_radiobuttonNull", phone: nil, completion: nil)
            return
        }
        let parameter: BillAndTaxesOperativeData = containerParameter()
        operativeData?.modeTypeSelector = type
        container?.saveParameter(parameter: parameter)
        container?.rebuildSteps()
        container?.operative.updateProgress(of: self)
        container?.stepFinished(presenter: self)
    }
    
    func didTapClose() {
        container?.cancelTouched(completion: nil)
    }
    
    func didTapFaqs() {
        let operativeData: BillAndTaxesOperativeData = containerParameter()
        let faqs = operativeData.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
            } ?? []
        self.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.BillAndTaxesFaq().page, extraParameters: [:])
        self.view.showFaqs(faqs)
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
