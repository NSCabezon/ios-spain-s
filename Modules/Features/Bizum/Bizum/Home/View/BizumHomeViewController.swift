//
//  BizumHomeViewController.swift
//  Bizum
//
//  Created by Carlos Gutiérrez Casado on 07/09/2020.
//

import UIKit
import UI
import CoreFoundationLib
import ESUI

protocol BizumHomeViewProtocol: class {
    func setRecentsEmptyView()
    func setRecentsLoading()
    func setRecents(_ items: [BizumHomeOperationViewModel])
    func disableGoToHistoric(_ disable: Bool)
    func setContactsLoading()
    func setContactsEmpty()
    func setContacts(_ items: [BizumHomeContactViewModel])
    func showFaqs(_ viewModels: [FaqsViewModel])
    func setOptions(_ items: [BizumHomeOptionViewModel])
    func showDialogPermission()
    func showAlertContactList()
    func showContacts(with: ContactListPresenter)
    func showBizumShoppingAlert()
}

final class BizumHomeViewController: UIViewController {
    @IBOutlet weak private var headerBackgroundView: UIView!
    @IBOutlet weak private var bizumGirlImage: UIImageView!
    @IBOutlet weak private var bottomBackgroundView: UIView!
    @IBOutlet weak private var bizumTitleImage: UIImageView!
    @IBOutlet weak private var settingsImage: UIImageView!
    @IBOutlet weak private var settingsLabel: UILabel!
    @IBOutlet weak private var settingsButton: UIButton!
    @IBOutlet weak private var scrollView: UIScrollView!
    // Contactos
    @IBOutlet weak private var contactsContainerView: UIView!
    @IBOutlet weak private var contactsCollectionView: BizumHomeContactCollectionView!
    // Separador
    @IBOutlet weak private var separatorView1: UIView!
    // Recientes
    @IBOutlet weak private var recentsContainerView: UIView!
    @IBOutlet weak private var recentsTitleLabel: UILabel!
    @IBOutlet weak private var recentsSubtitleLabel: UILabel!
    @IBOutlet weak private var recentsHistoricButton: UIButton!
    // Recientes - Lodaing
    @IBOutlet weak private var recentsLoadingView: UIView!
    @IBOutlet weak private var recentsLoadingImageView: UIImageView!
    // Recientes - List
    @IBOutlet weak private var recentsListView: UIView!
    @IBOutlet weak private var recentsCollectionView: BizumHomeOperationCollectionView!
    // Recientes - Vacio
    @IBOutlet weak private var recentsEmptyView: UIView!
    @IBOutlet weak private var recentsEmptyImage: UIImageView!
    @IBOutlet weak private var recentsEmptyTitleLabel: UILabel!
    @IBOutlet weak private var recentsEmptySubtitleLabel: UILabel!
    // Separador
    @IBOutlet weak private var separatorView2: UIView!
    // Todas las opciones
    @IBOutlet weak private var optionsContainerView: UIView!
    @IBOutlet weak private var optionsTitleLabel: UILabel!
    @IBOutlet weak private var optionsStackView: UIStackView!
    // Separador
    @IBOutlet weak private var separatorView3: UIView!
    @IBOutlet weak private var faqsContainerView: UIView!
    private let presenter: BizumHomePresenterProtocol
    var isSearchEnabled: Bool = true
    
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: BizumHomePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.recentsCollectionView.opearionDelegate = self
        self.contactsCollectionView.contactsCollectionViewDelegate = self
        self.presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isBeingPresented && !isMovingToParent { // Returned from detail view
            self.setupNavigationBar()
        }
    }
}

private extension BizumHomeViewController {
    func configureView() {
        self.view.backgroundColor = UIColor.skyGray
        self.scrollView.backgroundColor = UIColor.skyGray
        self.settingsButton.accessibilityIdentifier = AccessibilityBizum.bizumBtnSettings
        self.bizumTitleImage.image = ESAssets.image(named: "icnBizumBrandWhite")
        self.settingsImage.image = ESAssets.image(named: "icnSettingsWhite")
        self.headerBackgroundView.backgroundColor = .deepRed
        self.bottomBackgroundView.backgroundColor = .deepRed
        self.bizumGirlImage.image = ESAssets.image(named: "imgBgBizum")
        self.settingsLabel.font = UIFont.santander(size: 10)
        self.settingsLabel.textColor = UIColor.white
        self.settingsLabel.set(localizedStylableText: localized("generic_button_settings"))
        self.settingsLabel.accessibilityIdentifier = AccessibilityBizum.bizumLabelSettings
        self.configureContactsView()
        self.separatorView1.backgroundColor = UIColor.mediumSkyGray
        self.configureRecentsView()
        self.separatorView2.backgroundColor = UIColor.mediumSkyGray
        self.configureOptions()
        self.separatorView3.backgroundColor = .mediumSkyGray
    }
    
    func configureContactsView() {
        self.contactsContainerView.backgroundColor = UIColor.clear
        self.contactsCollectionView.backgroundColor = UIColor.clear
        self.contactsCollectionView.setup()
    }
    
    func configureRecentsView() {
        self.recentsContainerView.backgroundColor = UIColor.white
        self.recentsTitleLabel.font = UIFont.santander(family: .text, type: .bold, size: 18)
        self.recentsTitleLabel.textColor = UIColor.lisboaGray
        self.recentsTitleLabel.set(localizedStylableText: localized("bizum_title_recent"))
        self.recentsSubtitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.recentsSubtitleLabel.textColor = UIColor.lisboaGray
        self.recentsSubtitleLabel.set(localizedStylableText: localized("bizum_text_reuseRecents"))
        self.recentsHistoricButton.setTitleColor(.darkTorquoise, for: .normal)
        self.recentsHistoricButton.titleLabel?.font = .santander(family: .text, type: .regular, size: 14)
        self.recentsHistoricButton.set(localizedStylableText: localized("transfer_label_seeHistorical"), state: .normal)
        self.recentsHistoricButton.accessibilityIdentifier = AccessibilityBizum.bizumBtnHistorical
        self.recentsLoadingView.backgroundColor = UIColor.white
        self.recentsLoadingImageView.setSecondaryLoader()
        self.recentsListView.backgroundColor = UIColor.white
        self.recentsEmptyView.backgroundColor = UIColor.white
        self.recentsEmptyImage.image = Assets.image(named: "imgLeaves")
        self.recentsEmptyTitleLabel.font = UIFont.santander(family: .headline, type: .regular, size: 20)
        self.recentsEmptyTitleLabel.textColor = UIColor.lisboaGray
        self.recentsEmptyTitleLabel.set(localizedStylableText: localized("transfer_title_emptyView_recent"))
        self.recentsEmptySubtitleLabel.font = UIFont.santander(family: .headline, type: .regular, size: 15)
        self.recentsEmptySubtitleLabel.textColor = UIColor.lisboaGray
        self.recentsEmptySubtitleLabel.set(localizedStylableText: localized("bizum_text_emptyView_recent"))
        self.recentsTitleLabel.accessibilityIdentifier = AccessibilityBizum.bizumLabelRecentTitle
        self.recentsSubtitleLabel.accessibilityIdentifier = AccessibilityBizum.bizumLabelRecentSubTitle
        self.recentsCollectionView.accessibilityIdentifier = AccessibilityBizum.bizumListViewRecent
    }
    
    func setupNavigationBar() {
        let titleImage = TitleImage(
            image: ESAssets.image(named: "icnBizumHeaderWhite"),
            topMargin: 4,
            width: 14,
            height: 18
        )
        let builder = NavigationBarBuilder(
            style: .custom(background: .color(UIColor.deepRed), tintColor: .white),
            title: .titleWithImage(key: "toolbar_title_bizum", image: titleImage)
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    func configureOptions() {
        self.optionsContainerView.backgroundColor = .skyGray
        self.optionsTitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 18)
        self.optionsTitleLabel.textColor = UIColor.lisboaGray
        self.optionsTitleLabel.set(localizedStylableText: localized("bizum_title_allOptions"))
        self.optionsTitleLabel.accessibilityIdentifier = AccessibilityBizum.bizumOptionsTitleLabel
    }
    
    @IBAction func touchNewSend() {
        self.presenter.didSelectNewSend()
    }
    
    @IBAction func touchSettings() {
        self.presenter.didSelectSettings()
    }
    
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @IBAction func openHistoric() {
        self.presenter.didSelectRecents()
    }
    
    @objc func adjustButton() {
        self.navigateToSettings()
    }
}

extension BizumHomeViewController: BizumHomeViewProtocol {
    func setRecentsEmptyView() {
        self.recentsSubtitleLabel.isHidden = true
        self.recentsEmptyView.isHidden = false
        self.recentsLoadingView.isHidden = true
        self.recentsListView.isHidden = true
    }
    
    func setRecentsLoading() {
        self.recentsSubtitleLabel.isHidden = true
        self.recentsHistoricButton.isHidden = true
        self.recentsEmptyView.isHidden = true
        self.recentsLoadingView.isHidden = false
        self.recentsListView.isHidden = true
    }
    
    func setRecents(_ items: [BizumHomeOperationViewModel]) {
        self.recentsSubtitleLabel.isHidden = false
        self.recentsEmptyView.isHidden = true
        self.recentsLoadingView.isHidden = true
        self.recentsListView.isHidden = false
        self.recentsCollectionView.setViewModels(items)
    }

    func disableGoToHistoric(_ disable: Bool) {
        self.recentsHistoricButton.isHidden = disable
    }
    
    func setContactsLoading() {
        self.contactsCollectionView.showLoading()
    }
    
    func setContacts(_ items: [BizumHomeContactViewModel]) {
        self.contactsCollectionView.set(items)
    }
    
    func showFaqs(_ viewModels: [FaqsViewModel]) {
        let faqsView = FAQSView(faqs: viewModels, self)
        faqsView.configureTitle("faqs_label_otherConsultations")
        self.faqsContainerView.addSubview(faqsView)
        faqsView.topAnchor.constraint(equalTo: self.faqsContainerView.topAnchor, constant: 0.0).isActive = true
        faqsView.bottomAnchor.constraint(equalTo: self.faqsContainerView.bottomAnchor, constant: 0.0).isActive = true
        faqsView.leadingAnchor.constraint(equalTo: self.faqsContainerView.leadingAnchor, constant: 0.0).isActive = true
        faqsView.trailingAnchor.constraint(equalTo: self.faqsContainerView.trailingAnchor, constant: 0.0).isActive = true
    }
    
    func setContactsEmpty() {
        self.contactsCollectionView.setEmpty()
    }
    
    func setOptions(_ items: [BizumHomeOptionViewModel]) {
        for view in self.optionsStackView.arrangedSubviews {
            self.optionsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        for item in items {
            let view = BizumHomeOptionView()
            view.set(item)
            view.delegate = self
            self.optionsStackView.addArrangedSubview(view)
        }
    }
    
    // MARK: - Contact list
    func showAlertContactList() {
        let allowAction = LisboaDialogAction(title: localized("generic_button_allow"), type: .red, margins: (left: 16.0, right: 8.0), accesibilityIdentifier: BizumHomeAlertContactList.bizumBtnAllowed) {
            self.presenter.didAllowPermission()
        }
        let refuseAction = LisboaDialogAction(title: localized("generic_button_toRefuse"), type: .white, margins: (left: 16.0, right: 8.0), accesibilityIdentifier: BizumHomeAlertContactList.bizumBtnReject) { }
        LisboaDialog(
            items: [
                .margin(19.0),
                .image(LisboaDialogImageViewItem(image: ESAssets.image(named: "icnBizumContacts48"), size: (width: 56, height: 64))),
                .margin(6.0),
                .styledText(LisboaDialogTextItem(text: localized("bizum_alert_accessContactBook"), font: .santander(size: 29), color: .lisboaGray, alignament: .center, margins: (25, 25), accesibilityIdentifier: BizumHomeAlertContactList.bizumLabelTitle)),
                .margin(13.0),
                .styledText(LisboaDialogTextItem(text: localized("bizum_alert_appPermission"), font: .santander(family: .text, type: .light, size: 16.0), color: .lisboaGray, alignament: .center, margins: (16, 16), accesibilityIdentifier: BizumHomeAlertContactList.bizumLabelSubTitle)),
                .margin(30),
                .horizontalActions(HorizontalLisboaDialogActions(left: refuseAction, right: allowAction)),
                .margin(6)
            ],
            closeButtonAvailable: false
        ).showIn(self)
    }
    
    func showDialogPermission() {
        let acceptComponents = DialogButtonComponents(titled: localized("genericAlert_buttom_settings"), does: adjustButton)
        let cancelComponents = DialogButtonComponents(titled: localized("generic_button_cancel"), does: nil)
        self.showOldDialog(title: nil, description: localized("onboarding_alert_text_permissionActivation"), acceptAction: acceptComponents, cancelAction: cancelComponents, isCloseOptionAvailable: false)
    }
    
    func showBizumShoppingAlert() {
        let configureAction = VerticalLisboaDialogAction(
            title: localized("ganeric_label_knowMore"),
            type: .red,
            margins: (left: 16, right: 16),
            accesibilityIdentifier: AccessibilityBizum.bizumAlertBtnKnowMore,
            isCancelAction: false,
            action: presenter.didSelectKnowMoreOfShopping
        )
        let cancelAction = VerticalLisboaDialogAction(
            title: localized("generic_buttom_noThanks"),
            type: .custom(backgroundColor: .clear, titleColor: .darkTorquoise, font: .santander(size: 14)),
            margins: (left: 16, right: 16),
            accesibilityIdentifier: AccessibilityBizum.bizumAlertBtnNoThanks,
            isCancelAction: true,
            action: { }
        )
        LisboaDialog(
            items: [
                .margin(22),
                .styledText(LisboaDialogTextItem(text: localized("bizum_alertTitle_shoppingBizum"), font: .santander(size: 28), color: UIColor.black.withAlphaComponent(0.85), alignament: .center, margins: (25, 25), accesibilityIdentifier: AccessibilityBizum.bizumAlertTitleShoppingBizum)),
                .margin(18),
                .styledText(LisboaDialogTextItem(text: localized("bizum_alertText_shoppingBizum"), font: .santander(family: .text, type: .light, size: 16), color: UIColor.black.withAlphaComponent(0.85), alignament: .center, margins: (45, 45), accesibilityIdentifier: AccessibilityBizum.bizumAlertTextShoppingBizum)),
                .margin(30),
                .verticalAction(configureAction),
                .verticalAction(cancelAction),
                .margin(21)
            ],
            closeButtonAvailable: false
        ).showIn(self)
    }
    
    // MARK: - From contact list
    func showContacts(with presenter: ContactListPresenter) {
        let viewController = ContactListViewController(presenter: presenter)
        presenter.view = viewController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }
}

extension BizumHomeViewController: NavigationBarWithSearchProtocol {
    var searchButtonPosition: Int {
        return 1
    }
    
    func searchButtonPressed() {
        self.presenter.didSelectSearch()
    }
}

extension BizumHomeViewController: BizumHomeOperationCollectionViewDelegate {
    func didSelectOperation(_ viewModel: BizumHomeOperationViewModel) {
        self.presenter.didSelectOperation(viewModel.identifier)
    }
    
    func didSelectAllOperations() {
        self.presenter.didSelectRecentsList()
    }
    
    func didSelectOperationMultiple(_ viewModel: BizumHomeOperationViewModel) {
        self.presenter.didSelectOperation(viewModel.identifier)
    }
}

extension BizumHomeViewController: BizumHomeContactCollectionViewDelegate {
    func didSelectNewShipment() {
        self.presenter.didSelectNewSend()
    }
    
    func didSelectContact(_ viewModel: BizumHomeContactViewModel) {
        self.presenter.didSelectContact(viewModel)
    }
    
    func didSelectSearchContact() {
        self.presenter.didSelectSearchContact()
    }
}

extension BizumHomeViewController: FAQSViewDelegate {
    func didSelectVirtualAssistant() {
        self.presenter.didSelectVirtualAssistant()
    }
}

extension BizumHomeViewController: IdeaViewDelegate {
    func didExpandAnswer(question: String) {
        self.presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        self.presenter.trackFaqEvent(question, url: url)
    }
}
 
extension BizumHomeViewController: BizumHomeOptionViewDelegate {
    func didSelectOption(_ option: BizumHomeOptionViewModel?) {
        self.presenter.didSelectOption(option)
    }
}

extension BizumHomeViewController: SystemSettingsNavigatable { }
extension BizumHomeViewController: OldDialogViewPresentationCapable {}
