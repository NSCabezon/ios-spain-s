import UIKit
import CoreFoundationLib
import UI
import CoreDomain

protocol HelperCenterViewProtocol: AnyObject {
    func showView(faqsViewModel: HelpCenterFaqsViewModel?,
                  contactsViewModel: HelpCenterContactsViewModel?,
                  emergencyViewModel: HelpCenterEmergencyViewModel?,
                  helpCenter: [HelpCenterTipViewModel]?,
                  offerDateOffer: ContactsSimpleViewModel?)
    func cancelTransfer(_ phone: String)
    func showLoadingView(_ completion: (() -> Void)?)
    func hideLoadingView(_ completion: (() -> Void)?)
}

public protocol HelpCenterSearchViewDelegate: AnyObject {
    func didTapGlobalSearch()
}

protocol IsStackeable {}

final class HelperCenterViewController: UIViewController, RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
    lazy var tipsView: HelpCenterTipsView = {
        let view = HelpCenterTipsView(frame: .zero)
        view.tipDelegate = self
        view.setStyle(.helpCenterTipsStyle())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setCollectionAccessibilityIdentifier("helpCenter_tips_carousel")
        view.setTitleAccessibilityIdentifier("helpCenter_tips_title")
        return view
    }()
    private let presenter: HelperCenterPresenterProtocol
    private var emergencyView = HelpCenterEmergencyView()
    private var offerView = HelpCenterLocationView()
    private var isEmergencyExpanded: Bool = false
    private var contactsView = ContactsStackView()
    private var flipTimer: Timer?
    private var selectedViewModel: ContactsFlipViewViewModel?
    private var searchView = HelpCenterSearchView()
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var separatorView: UIView!
    
    init(presenter: HelperCenterPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "HelperCenterViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.viewDidLoad()
        separatorView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpNavigationBar()
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @objc func searchButtonPressed() {
        self.presenter.didSelectSearch()
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
}

extension HelperCenterViewController: HelperCenterViewProtocol {
    func showView(faqsViewModel: HelpCenterFaqsViewModel?,
                  contactsViewModel: HelpCenterContactsViewModel?,
                  emergencyViewModel: HelpCenterEmergencyViewModel?,
                  helpCenter: [HelpCenterTipViewModel]?,
                  offerDateOffer: ContactsSimpleViewModel?) {
        self.stackView.isHidden = true
        self.stackView.alpha = 0
        self.addFaqs(faqsViewModel)
        self.addSearchView()
        self.addContacts(contactsViewModel)
        self.addEmergencies(emergencyViewModel, isExpanded: self.isEmergencyExpanded)
        self.addOfferView(offerDateOffer)
        self.addHelpCenter(helpCenter: helpCenter)
        self.hideLoadingView {
            UIView.animate(withDuration: 0.25) {
                self.stackView.isHidden = false
                self.stackView.alpha = 1
            }
        }
    }
    
    func cancelTransfer(_ phone: String) {
        let items: [LisboaDialogItem] = [
            LisboaDialogItem.margin(22),
            LisboaDialogItem.styledText(LisboaDialogTextItem(text: localized("helpCenter_alertTitle_cancelTransfer"), font: UIFont.santander(family: FontFamily.headline, type: FontType.regular, size: 22), color: UIColor.black, alignament: NSTextAlignment.center, margins: (left: 16, right: 16), accesibilityIdentifier: "helpCenter_alertTitle_cancelTransfer")),
            LisboaDialogItem.margin(20),
            LisboaDialogItem.styledText(LisboaDialogTextItem(text: localized("helpCenter_alertText_cancelTransfer"), font: UIFont.santander(family: FontFamily.headline, type: FontType.regular, size: 16), color: UIColor.black, alignament: NSTextAlignment.center, margins: (left: 16, right: 16), accesibilityIdentifier: "helpCenter_alertText_cancelTransfer")),
            LisboaDialogItem.margin(32),
            LisboaDialogItem.verticalAction(VerticalLisboaDialogAction(title: localized("general_button_call", [StringPlaceholder(StringPlaceholder.Placeholder.phone, phone)]), type: LisboaDialogActionType.white, margins: (left: 16, right: 16), accesibilityIdentifier: "helpCenter_cancelTransfer_callButton", action: { [weak self] in
                self?.presenter.phoneCall(.superlinea, true)
            })),
            LisboaDialogItem.margin(26),
            LisboaDialogItem.verticalAction(VerticalLisboaDialogAction(title: localized("generic_button_understand"), type: LisboaDialogActionType.red, margins: (left: 16, right: 16), accesibilityIdentifier: "helpCenter_cancelTransfer_understandButton", action: { [weak self] in
                self?.presenter.didSelectUnderstandButton()
            })),
            LisboaDialogItem.margin(15)
        ]
        let dialog = LisboaDialog(items: items, closeButtonAvailable: false)
        
        dialog.showIn(self)
    }
}

extension HelperCenterViewController: HelpCenterTipsViewDelegate {
    func didSelectTip(_ viewModel: Any) {
        guard let viewModel = viewModel as? HelpCenterTipViewModel else { return }
        self.presenter.didSelectTip(viewModel)
    }
    
    func didSelectSeeAllTips() {
        self.presenter.didSelectSeeAllTips()
    }
    
    func scrollViewDidEndDecelerating() {
        presenter.tipCollectionViewDidEndDecelerating()
    }
}
extension HelperCenterViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        separatorView.isHidden = self.scrollView.contentOffset.y <= 0.0
    }
}

extension HelperCenterViewController: VirtualAssistantSimpleViewProtocol {
    func didTapView(fromOtherConsultations: Bool) {
        self.presenter.didTapVirtualAssistantView(fromOtherConsultations: fromOtherConsultations)
    }
}

extension HelperCenterViewController: ContactsSimpleViewProtocol {
    func didTapSimpleView(action: ContactsSimpleViewModelAction) {
        self.presenter.didTapSimpleView(action: action)
    }
}

private extension HelperCenterViewController {
    func setupView() {
        self.view.backgroundColor = UIColor.skyGray
    }
    
    func setUpNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .tooltip(
                titleKey: "toolbar_title_helpCenter",
                type: .red,
                action: { [weak self] sender in
                    self?.showGeneralTooltip(sender)
                }
            )
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    func showGeneralTooltip(_ sender: UIView) {
        HelpCenterTooltip().showTooltip(in: self, from: sender)
    }
    
    func addHelpCenter(helpCenter: [HelpCenterTipViewModel]?) {
        guard let helpCenter = helpCenter, !helpCenter.isEmpty else { return }
        tipsView.setViewModels(helpCenter)
        stackView.addArrangedSubview(tipsView)
    }
    
    func addFaqs(_ faqsViewModel: HelpCenterFaqsViewModel?) {
        guard let faqsViewModel = faqsViewModel else { return }
        // Add Virtual Assistant Header
        let faqsView = VirtualAssistantFaqsView()
        let isVirtualAssistantEnabled = faqsViewModel.isVirtualAssistantEnabled
        if isVirtualAssistantEnabled {
            let headerView = VirtualAssistantHeaderView()
            faqsView.stackViewFaqs.addArrangedSubview(headerView)
            headerView.delegate = self
        } else {
            let headerView = VirtualAssistantUnableHeaderView()
            faqsView.stackViewFaqs.addArrangedSubview(headerView)
        }
        // Add "Most searched" view
        let simpleViewSearched = VirtualAssistantSimpleView()
        simpleViewSearched.configureLabels(isFirstView: true)
        faqsView.stackViewFaqs.addArrangedSubview(simpleViewSearched)
        // Add Faqs views
        let maxElement = faqsViewModel.faqs.count
        faqsViewModel.faqs.enumerated().forEach { (index, faq) in
            let expandableView = VirtualAssistantExpandableView()
            expandableView.configureLabels(faq)
            expandableView.delegate = self
            expandableView.separatorView.isHidden = index == maxElement
            faqsView.stackViewFaqs.addArrangedSubview(expandableView)
        }
        if isVirtualAssistantEnabled {
            let simpleViewOtherConsults = VirtualAssistantSimpleView()
            simpleViewOtherConsults.configureLabels(isFirstView: false)
            faqsView.stackViewFaqs.addArrangedSubview(simpleViewOtherConsults)
            simpleViewOtherConsults.delegate = self
        }
        self.stackView.addArrangedSubview(faqsView)
    }
    
    func addSearchView() {
        searchView.helpCenterDelegate = self
        stackView.addArrangedSubview(searchView)
    }
    
    func addContacts(_ viewModel: HelpCenterContactsViewModel?) {
        guard let viewModel = viewModel, !viewModel.isEmpty else { return }
        addSuperlineView(viewModel.superline)
        addProductOneVIP(viewModel.isProductOneVIP)
        addPermanentAttention(viewModel.permanetAttention)
        addChat(viewModel.isChatEnabled, isUserSmart: viewModel.isUserSmart)
        addWhatsapp(viewModel.whatsApp)
        stackView.addArrangedSubview(contactsView)
    }
    
    func addSuperlineView(_ viewModel: HelpCenterContactsSupelineViewModel?) {
        guard let superline = viewModel else { return contactsView.viewSuperline.isHidden = true }
        contactsView.flipView.setModel(viewModel: ContactsFlipViewViewModel(title: (superline.title ?? ""),
                                                                            subtitle: localized(superline.description ?? ""),
                                                                            icon: "icnHelpCall",
                                                                            phoneIcon: "icnCornerPhone3",
                                                                            phoneNumbers: superline.numbers,
                                                                            flipViewType: .superline))
        superline.numbers.forEach {
            let callView = HelpCenterImageLabelCallView()
            let phoneLocalized =  localized("helpCenter_button_helpCall", [StringPlaceholder(StringPlaceholder.Placeholder.phone, $0)])
            let viewModel = HelpCenterImageLabelCallViewModel(phone: phoneLocalized,
                                                              action: .superlinea)
            callView.setViewModel(viewModel)
            callView.delegate = self
            callView.setAccessibilityIdentifiers(suffix: "_big")
            contactsView.phoneNumbersStackView.addArrangedSubview(callView)
        }
        contactsView.flipCallView.isHidden = true
        contactsView.flipView.delegate = self
        contactsView.flipView.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterBtnHelpCall.rawValue
        contactsView.flipCallView.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterBtnHelpCallFlipped.rawValue
    }
    
    func addProductOneVIP(_ isProductOneVIP: Bool) {
        guard isProductOneVIP else { return }
        let productOneVIPView = HelpCenterProductOneVIPView()
        productOneVIPView.tapAction = { [weak self] in
            self?.presenter.didSelectProductOneVIP()
        }
        self.contactsView.stackView.addArrangedSubview(productOneVIPView)
        contactsView.flipView.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterBtnPlanOne.rawValue
        contactsView.flipCallView.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterBtnPlanOneFlipped.rawValue
    }
    
    func addPermanentAttention(_ viewModel: PermanentAttentionViewModel?) {
        let permanentAttentionView = PermanentAttentionView()
        self.contactsView.stackView.addArrangedSubview(permanentAttentionView)
        contactsView.flipView.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterBtnPermanentAttention.rawValue
        contactsView.flipCallView.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterBtnPermanentAttentionFlipped.rawValue
        permanentAttentionView.setViewModel(viewModel)
    }
    
    func addChat(_ chatEnabled: Bool, isUserSmart: Bool) {
        guard chatEnabled else { return }
        let chatView = ContactsSimpleView()
        chatView.setModel(viewModel: ContactsSimpleViewModel(title: localized("helpCenter_button_chat"),
                                                             subtitle: localized(isUserSmart ? "support_subtitle_chatSmart" : "support_subtitle_chat"),
                                                             icon: "icnHelpChat",
                                                             action: .chat))
        chatView.delegate = self
        contactsView.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterBtnHelpChat.rawValue
        contactsView.stackView.addArrangedSubview(chatView)
    }
    
    func addWhatsapp(_ viewModel: HelpCenterContactsWhatsAppViewModel?) {
        guard let whatsApp = viewModel else { return }
        let whatsappView = ContactsSimpleView()
        whatsappView.setModel(viewModel: ContactsSimpleViewModel(
            title: localized("helpCenter_button_whatsapp"),
            subtitle: localized(whatsApp.hint ?? ""),
            icon: "icnHelpWhatsapp",
            action: .whatsapp
        ))
        whatsappView.delegate = self
        contactsView.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterBtnHelpWhatsapp.rawValue
        contactsView.stackView.addArrangedSubview(whatsappView)
    }
    
    func addEmergencies(_ emergencyViewModel: HelpCenterEmergencyViewModel?, isExpanded: Bool) {
        guard let emergencyViewModel = emergencyViewModel else { return }
        if emergencyViewModel.stolen == nil {
            self.emergencyView.disableStolenCardView()
        }
        stackView.addArrangedSubview(emergencyView)
        _ = addHeader("helpCenter_label_emergencies", toStackView: emergencyView.stackView)
        addEmergencyBody(emergencyViewModel)
        addEmergencyFooter()
    }
    
    func addEmergencyBody(_ emergencyViewModel: HelpCenterEmergencyViewModel) {
        let factory: HelpCenterFactory = HelpCenterFactory()
        _ = factory.getHelpCenterEmergency(emergencyViewModel).map { viewModel in
            guard let view = createEmergencyView(viewModel) else { return }
            emergencyView.stackView.addArrangedSubview(view)
        }
        updateStackViewEmergency(hide: self.isEmergencyExpanded)
    }
    
    func createEmergencyView(_ viewModel: HelpCenterEmergencyItemViewModel) -> UIView? {
        switch viewModel.action {
        case .stolenCard(let phoneNumber, _):
            emergencyView.flipView?.setModel(viewModel: ContactsFlipViewViewModel(title: viewModel.title.text,
                                                                                  subtitle: viewModel.subtitle,
                                                                                  icon: "icnStolenCard",
                                                                                  phoneIcon: "icnCornerPhone3",
                                                                                  phoneNumbers: phoneNumber,
                                                                                  flipViewType: .stolen))
            emergencyView.flipView?.delegate = self
            emergencyView.flipCallView?.isHidden = true
            emergencyView.flipView?.accessibilityIdentifier = viewModel.action.accesibilityId()
            emergencyView.flipCallView?.accessibilityIdentifier = viewModel.action.accesibilityIdFlipped()
            for phone in phoneNumber {
                let callView = ContactsFlipCallView()
                callView.setModel(ContactsFlipViewViewModel(title: "",
                                                            subtitle: localized(""),
                                                            icon: "icnPhoneWhite",
                                                            phoneIcon: "",
                                                            phoneNumbers: phoneNumber,
                                                            flipViewType: .stolen),
                                  phoneNumber: phone)
                callView.delegate = self
                emergencyView.phoneNumbersStackView?.addArrangedSubview(callView)
            }
            return emergencyView.stolenCardView
        case .superlinea:
            let view = HelpCenterImageLabelView()
            view.setViewModels(viewModel)
            view.delegate = self
            let callView = createCallPhoneView(action: .superlinea)
            view.callView.addSubview(callView)
            callView.fullFit()
            return view
        case .reportFraud:
            let view = HelpCenterImageLabelView()
            view.setViewModels(viewModel)
            view.delegate = self
            let callView = createCallPhoneView(action: .reportFraud)
            view.callView.addSubview(callView)
            callView.fullFit()
            return view
        case .blockSign, .pin, .cvv, .cash, .cancelTransfer, .chat, .sendMoney, .changeMagic:
            let view = HelpCenterImageLabelView()
            view.setViewModels(viewModel)
            view.delegate = self
            return view
        }
    }
    
    func addOfferView(_ offerDate: ContactsSimpleViewModel?) {
        guard offerDate != nil else { return }
        self.stackView.addArrangedSubview(self.offerView)
        _ = self.addHeader("helpCenter_label_office", toStackView: self.offerView.stackView)
        self.addOfficeDateOffer(offerDate)
    }
    
    func addOfficeDateOffer(_ offerDate: ContactsSimpleViewModel?) {
        guard let offerDate = offerDate else { return }
        let offerDateView = ContactsSimpleView()
        offerDateView.setModel(viewModel: offerDate)
        offerDateView.delegate = self
        offerDateView.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterBtnOfficeOffer.rawValue
        self.offerView.stackView.addArrangedSubview(offerDateView)
    }
    
    func addHeader(_ title: String, toStackView: UIStackView? = nil) -> UIView {
        let configuration = LabelTooltipViewConfiguration(
            text: localized(title),
            left: 0.0,
            right: 0.0,
            top: 20.0,
            bottom: 0.0,
            font: .santander(family: .text, type: .bold, size: 20.0),
            textColor: .lisboaGray,
            labelAccessibilityID: title)
        let labelView = LabelTooltipView(configuration: configuration, labelIdentifier: title)
        if toStackView != nil {
            toStackView?.addArrangedSubview(labelView)
        }
        return labelView
    }
    
    func addEmergencyFooter() {
        let footView = HelpCenterEmergencyFootView()
        let title = self.isEmergencyExpanded ? "helpCenter_label_lessOptions" : "helpCenter_label_moreOptions"
        footView.setViewModel(HelpCenterEmergencyFootViewModel(title: localized(title), isExpanded: self.isEmergencyExpanded))
        footView.delegate = self
        emergencyView.stackView.addArrangedSubview(footView)
    }
    
    func updateStackViewEmergency(hide: Bool) {
        emergencyView.stackView.arrangedSubviews.forEach { view in
            // Hide some views
            if view is ContactsFlipView || view is LabelTooltipView {
                view.isHidden = false
            } else if view is HelpCenterEmergencyFootView {
                view.isHidden = false
                let title = hide ? "helpCenter_label_lessOptions" : "helpCenter_label_moreOptions"
                (view as? HelpCenterEmergencyFootView)?.setViewModel(HelpCenterEmergencyFootViewModel(title: localized(title), isExpanded: hide))
            } else {
                view.isHidden = !hide
            }
        }
        emergencyView.stolenCardView?.isHidden = false
        emergencyView.flipView?.isHidden = false
    }
    
    func createCallPhoneView(action: HelpCenterEmergencyAction) -> UIView {
        guard let phone = self.presenter.getPhone(action: action) else { return UIView() }
        let view = HelpCenterImageLabelCallView()
        let phoneLocalized =  localized("helpCenter_button_helpCall", [StringPlaceholder(StringPlaceholder.Placeholder.phone, phone)])
        view.setViewModel(HelpCenterImageLabelCallViewModel(phone: phoneLocalized, action: action))
        view.delegate = self
        return view
    }
    
    @objc func openMenu() {
        self.presenter.didSelectMenu()
    }
}

extension HelperCenterViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return nil
    }
}

extension HelperCenterViewController: HelpCenterImageLabelViewDelegate {
    func didSelect(_ viewModel: HelpCenterEmergencyItemViewModel) {
        self.presenter.didSelectEmergency(action: viewModel.action, cancelTransferAlert: false)
    }
}

extension HelperCenterViewController: HelpCenterEmergencyFootViewDelegate {
    func didTap() {
        self.isEmergencyExpanded = !self.isEmergencyExpanded
        UIView.animate(withDuration: 0.3) {
            self.updateStackViewEmergency(hide: self.isEmergencyExpanded)
        }
    }
}

extension HelperCenterViewController: ContactsFlipViewViewDelegate {
    func didSelectFlipView(_ viewModel: ContactsFlipViewViewModel) {
        self.selectedViewModel = viewModel
        switch viewModel.flipViewType {
        case .superline:
            UIView.flipView(viewToShow: self.contactsView.flipCallView,
                            viewToHide: self.contactsView.flipView,
                            flipBackIn: 2.0)
        case .stolen:
            guard let flipCallView = self.emergencyView.flipCallView,
                  let flipView = self.emergencyView.flipView
            else { return }
            UIView.flipView(viewToShow: flipCallView,
                            viewToHide: flipView,
                            flipBackIn: 2.0)
        }
    }
}

extension HelperCenterViewController: ContactsFlipCallViewDelegate {
    func didSelectCall(_ phoneNumber: String) {
        presenter.phoneCall(phoneNumber)
    }
}

extension HelperCenterViewController: HelpCenterImageLabelCallViewDelegate {
    func didSelectPhoneCall(_ viewModel: HelpCenterImageLabelCallViewModel) {
        self.presenter.phoneCall(viewModel.action, false)
    }
}

extension HelperCenterViewController: HelpCenterSearchViewDelegate {
    func didTapGlobalSearch() {
        presenter.didTapGlobalSearch()
    }
}

extension HelperCenterViewController: VirtualAssistantExpandableViewDelegate {
    func didSelectView() {
        presenter.didSelectFaqView()
    }
    
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension HelperCenterViewController: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        return self
    }
    
    func showLoadingView(_ completion: (() -> Void)?) {
        self.showLoading(completion: completion)
    }
    
    func hideLoadingView(_ completion: (() -> Void)?) {
        self.dismissLoading(completion: completion)
    }
}

extension HelperCenterViewController: IsStackeable {}
