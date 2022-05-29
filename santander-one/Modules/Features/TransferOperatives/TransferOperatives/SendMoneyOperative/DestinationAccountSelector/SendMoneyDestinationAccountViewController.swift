//
//  SendMoneyDestinationAccountViewController.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 22/9/21.
//

import UIKit
import Operative
import UIOneComponents
import CoreFoundationLib
import CoreDomain
import UI
import IQKeyboardManagerSwift

protocol SendMoneyDestinationAccountView: OperativeView {
    func showSelectedAccount(viewModel: OneAccountsSelectedCardViewModel)
    func configureFavoritesView(title: LocalizedStylableText, viewStatus: SendMoneyDestinationAccountFavoritesView.ViewStatus)
    func showAllFavorites(_ favorites: [OneFavoriteContactCardViewModel])
    func closeBottomSheet()
    func filterFavorites(favorites: [OneFavoriteContactCardViewModel])
    func scrollToSelectedFavorite()
    func configureLastTransfersView(title: LocalizedStylableText, viewStatus: SendMoneyDestinationAccountLastTransfersView.ViewStatus)
    func scrollToSelectedLastTransfer()
    func reloadLastTransfersView()
    func showLoading()
    func hideLoading()
    func setEnabledFloattingButton(_ enabled: Bool)
    func showBankNameAndLogo(_ iban: IBANRepresentable, name: String)
    func showAliasRecipient(saveToFavourite: Bool, alias: String?)
    func showAliasHelper(helperType: NewRecipientAliasHelperViewType)
    func toggleViews(_ views: [SendMoneyDestinationAccountViewController.DestinationViews])
    func setNewRecipientData(_ iban: String?, name: String?, alias: String?)
    func setNewRecipientError()
    func setNewRecipientCheckbox(status: OneStatus)
    func resetNewRecipient()
    func showAllCountries(listItems: [OneSmallSelectorListViewModel], carouselItems: [OneSmallSelectorListViewModel])
    func setCountries(listItems: [OneSmallSelectorListViewModel], carouselItems: [OneSmallSelectorListViewModel])
}

final class SendMoneyDestinationAccountViewController: UIViewController {
    private enum Constants {
        static let defaultIbanHelper: String = "xx_en_ibanHelper"
    }

    public enum DestinationViews {
        case favorite
        case lastTransfer
        case newRecipient
    }

    @IBOutlet private weak var destinationOptionsStackView: UIStackView!
    @IBOutlet private weak var selectedAccountView: OneAccountsSelectedCardView!
    @IBOutlet weak var floatingButton: OneFloatingButton!
    @IBOutlet weak var floatingButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    private let dependenciesResolver: DependenciesResolver
    private let presenter: SendMoneyDestinationAccountPresenterProtocol
    private lazy var sendMoneyModifier: SendMoneyModifierProtocol? = {
        return self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)
    }()
    private lazy var showFavorite: Bool = {
        return sendMoneyModifier?.shouldShowSaveAsFavourite ?? true
    }()
    private lazy var favoriteContactsView: SendMoneyDestinationAccountFavoritesView = {
        let favoritesView = SendMoneyDestinationAccountFavoritesView()
        favoritesView.delegate = self
        return favoritesView
    }()
    private lazy var fullFavoritesView: SendMoneyDestinationAccountFullFavoritesListView = {
        let fullFavoritesView = SendMoneyDestinationAccountFullFavoritesListView()
        fullFavoritesView.delegate = self
        fullFavoritesView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        return fullFavoritesView
    }()
    private lazy var countriesSelectionView: SelectionListView = {
        let countriesSelectionView = SelectionListView()
        countriesSelectionView.setSelectionType(.countries)
        countriesSelectionView.delegate = self
        countriesSelectionView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        return countriesSelectionView
    }()
    
    private lazy var lastTransfersView: SendMoneyDestinationAccountLastTransfersView = {
        let lastTransfersView = SendMoneyDestinationAccountLastTransfersView()
        lastTransfersView.delegate = self
        return lastTransfersView
    }()
    private lazy var newRecipientView: NewRecipientView = {
        let shouldShowChangeCountryButton: Bool = self.sendMoneyModifier?.isEnabledChangeCountry ?? false
        let view = NewRecipientView(
            dependenciesResolver: self.dependenciesResolver,
            configuration: self.presenter.newRecipientConfiguration,
            showIbanHelp: self.showIbanHelp,
            showAliasHelper: self.showAliasHelper,
            didTapChangeCountry: shouldShowChangeCountryButton ? self.didTapChangeCountry : nil
        )
        view.delegate = self
        if !self.showFavorite {
            view.hideSaveFavourite()
        }
        return view
    }()
    private lazy var aliasHelperView: NewRecipientAliasHelperView = {
        let aliasHelperView = NewRecipientAliasHelperView()
        aliasHelperView.delegate = self
        return aliasHelperView
    }()
    
    var loadingView: UIView?

    init(presenter: SendMoneyDestinationAccountPresenterProtocol, dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: "SendMoneyDestinationAccountViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupComponets()
        self.setupStackView()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
        self.setupNavigationBar()
        self.configureKeyboardListener()
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        IQKeyboardManager.shared.enable = true
    }
}

private extension SendMoneyDestinationAccountViewController {
    var ibanHelpView: UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 405).isActive = true
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.fullFit(topMargin: 0, bottomMargin: 16, leftMargin: 0, rightMargin: 0)
        imageView.contentMode = .scaleAspectFit
        let imageUrl = self.presenter.newRecipientConfiguration.ibanHelpImageUrl
        _ = imageView.setImage(url: imageUrl, placeholder: nil, completion: { [weak self] image in
            guard image == nil else { return }
            _ = imageView.setImage(url: self?.presenter.newRecipientConfiguration.defaultIbanHelpImageUrl, placeholder: Assets.image(named: Constants.defaultIbanHelper))
        })
        return view
    }
    
    func setupNavigationBar() {
        let stepInfo = self.getOperativeStep()
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_recipients")
            .setAccessibilityTitleValue(value: localized("siri_voiceover_step", [.init(.number, stepInfo[0]),
                                                                                 .init(.number, stepInfo[1])]).text)
            .setLeftAction(.back, customAction: self.didTapBack)
            .setRightAction(.help) {
                Toast.show(localized("generic_alert_notAvailableOperation"))
            }
            .setRightAction(.close) {
                self.presenter.didSelectClose()
            }
            .build(on: self)
    }

    func getSeparatorView() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .oneMediumSkyGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1.0),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.0),
            separator.topAnchor.constraint(equalTo: container.topAnchor, constant: 0.0),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.0),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0.0),
        ])
        return container
    }

    func setupStackView() {
        self.destinationOptionsStackView.spacing = 20.0
        self.destinationOptionsStackView.distribution = .equalSpacing
        let views = [
            self.favoriteContactsView,
            self.getSeparatorView(),
            self.lastTransfersView,
            self.getSeparatorView(),
            self.newRecipientView
        ]
        views.forEach { self.destinationOptionsStackView.addArrangedSubview($0) }
    }
    
    func didTapBack() {
        self.presenter.didSelectBack()
    }
    
    func setupComponets() {
        self.selectedAccountView.delegate = self
        self.floatingButton.configureWith(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(
                    title: localized("generic_button_continue"),
                    subtitle: self.presenter.getSubtitleInfo(),
                    icons: .right,
                    fullWidth: false)
            ),
            status: .ready)
        self.floatingButton.isEnabled = false
        self.floatingButton.addTarget(self, action: #selector(floatingButtonDidPressed), for: .touchUpInside)
        self.newRecipientView.checkbox.delegate = self
    }
    
    func configureKeyboardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    func showIbanHelp() {
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: self,
                         type: .custom(isPan: true, bottomVisible: false),
                         component: .all,
                         view: self.ibanHelpView,
                         imageAccessibilityLabel: localized("voiceover_descriptionIban").text,
                         btnCloseAccessibilityLabel: localized("voiceover_closeHelp").text)
    }
    
    func getOperativeStep() -> [String]{
        let stepOfSteps = self.presenter.getStepOfSteps()
        let step = String(stepOfSteps[0])
        let total = String(stepOfSteps[1])
        return [step, total]
    }
    
    func setAccessibilityInfo() {
        let stepInfo = self.getOperativeStep()
        self.floatingButton.accessibilityLabel = localized("voiceover_button_continueAmountDate", [StringPlaceholder(.number, stepInfo[0]),
                                                                                                   StringPlaceholder(.number, stepInfo[1])]).text
        self.floatingButton.accessibilityHint = self.floatingButton.isEnabled ? localized("voiceover_activated") : localized("voiceover_deactivated")
        UIAccessibility.post(notification: .layoutChanged, argument: self.navigationItem.titleView)
    }
    
    func updateFloatingButtonAccessibility() {
        self.floatingButton.accessibilityHint = self.floatingButton.isEnabled ? localized("voiceover_activated") : localized("voiceover_deactivated")
    }
    
    @objc func floatingButtonDidPressed() {
        self.presenter.didPressedFloatingButton()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

extension SendMoneyDestinationAccountViewController: SendMoneyDestinationAccountView {

    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
    
    func showSelectedAccount(viewModel: OneAccountsSelectedCardViewModel) {
        self.selectedAccountView.setupAccountViewModel(viewModel)
    }

    func configureFavoritesView(title: LocalizedStylableText, viewStatus: SendMoneyDestinationAccountFavoritesView.ViewStatus) {
        self.favoriteContactsView.configureFavoritesView(title: title, viewStatus: viewStatus)
    }
    
    func showAllFavorites(_ favorites: [OneFavoriteContactCardViewModel]) {
        let bottomSheet = BottomSheet()
        self.fullFavoritesView.clearInput()
        self.fullFavoritesView.setFavorites(favorites)
        bottomSheet.show(in: self,
                         type: .top(isPan: true),
                         component: .all,
                         view: fullFavoritesView,
                         btnCloseAccessibilityLabel: localized("voiceover_close").text)
    }
    
    func showAllCountries(listItems: [OneSmallSelectorListViewModel],
                          carouselItems: [OneSmallSelectorListViewModel]) {
        let bottomSheet = BottomSheet()
        self.countriesSelectionView.clearInput()
        self.countriesSelectionView.setItems(listItems: listItems, carouselItems: carouselItems)
        bottomSheet.show(in: self,
                         type: .custom(height: self.view.frame.height, isPan: true),
                         component: .all,
                         view: countriesSelectionView,
                         btnCloseAccessibilityLabel: localized("voiceover_close").text)
    }
    
    func setCountries(listItems: [OneSmallSelectorListViewModel],
                      carouselItems: [OneSmallSelectorListViewModel]) {
        self.countriesSelectionView.setItems(listItems: listItems, carouselItems: carouselItems)
    }
    
    func closeBottomSheet() {
        self.presentedViewController?.dismiss(animated: true)
    }
    
    func filterFavorites(favorites: [OneFavoriteContactCardViewModel]) {
        self.fullFavoritesView.setFavorites(favorites)
    }
    
    func scrollToSelectedFavorite() {
        self.favoriteContactsView.scrollToSelectedFavorite()
    }

    func configureLastTransfersView(title: LocalizedStylableText, viewStatus: SendMoneyDestinationAccountLastTransfersView.ViewStatus) {
        self.lastTransfersView.configureLastTransfersView(title: title, viewStatus: viewStatus)
    }

    func scrollToSelectedLastTransfer() {
        self.lastTransfersView.scrollToSelectedLastTransfer()
    }

    func reloadLastTransfersView() {
        self.lastTransfersView.reloadLastTransfers()
    }
    
    func setEnabledFloattingButton(_ enabled: Bool) {
        self.floatingButton.isEnabled = enabled
        self.updateFloatingButtonAccessibility()
    }
    
    func showBankNameAndLogo(_ iban: IBANRepresentable, name: String) {
        self.newRecipientView.showBankNameAndLogo(iban, name: name)
    }
    
    func showAliasRecipient(saveToFavourite: Bool, alias: String?) {
        self.newRecipientView.showAliasRecipient(saveToFavourite: saveToFavourite, alias: alias)
    }
    
    func showAliasHelper(helperType: NewRecipientAliasHelperViewType = .aliasInfo) {
        let viewModel = NewRecipientAliasHelperViewType.getViewModel(for: helperType)
        self.aliasHelperView.setViewModel(viewModel)
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: self,
                         type: .custom(isPan: true, bottomVisible: true),
                         component: .all,
                         view: self.aliasHelperView)
    }
    
    func toggleViews(_ views: [DestinationViews]) {
        self.favoriteContactsView.toggleView(opened: views.contains { $0 == .favorite })
        self.lastTransfersView.toggleView(opened: views.contains { $0 == .lastTransfer })
        self.newRecipientView.toggleView(opened: views.contains { $0 == .newRecipient })
    }
    
    func setNewRecipientData(_ iban: String?, name: String?, alias: String?) {
        self.newRecipientView.setFavoriteCheckBox(status: alias != nil ? .activated : .inactive)
        self.newRecipientView.setInputText(iban, name: name, alias: alias)
    }

    func setNewRecipientError() {
        self.newRecipientView.setIBANError()
    }

    func setNewRecipientCheckbox(status: OneStatus) {
        self.newRecipientView.setFavoriteCheckBox(status: status)
        if !self.showFavorite {
            self.newRecipientView.hideSaveFavourite()
        }
    }
    
    func didTapChangeCountry() {
        self.presenter.didTapChangeCountries()
    }
    
    func resetNewRecipient() {
        self.newRecipientView.resetInputSpecialIBAN()
    }
}

// MARK: - OneAccountsSelectedCardView Delegate
extension SendMoneyDestinationAccountViewController: OneAccountsSelectedCardDelegate {
    func didSelectOriginButton() {
        self.presenter.changeOriginAccount()
    }

    func didSelectDestinationButton() { }
}

// MARK: - FavoritesView Delegate
extension SendMoneyDestinationAccountViewController: SendMoneyDestinationAccountFavoritesViewDelegate {
    func didSelectFavoriteAccount(_ cardViewModel: OneFavoriteContactCardViewModel) {
        self.presenter.didSelectFavoriteAccount(cardViewModel, isFromList: false)
    }

    func didSelectSeeAllFavorites() {
        self.presenter.didSelectSeeAllFavorites()
    }
}

// MARK: - NewRecipientView Delegate
extension SendMoneyDestinationAccountViewController: NewRecipientViewDelegate {
    
    func didSelectView(_ view: UIView) {
        var openedViews: [DestinationViews] = []
        if view == self.favoriteContactsView {
            openedViews.append(.favorite)
        } else if view == self.lastTransfersView {
            openedViews.append(.lastTransfer)
        } else if view == self.newRecipientView {
            openedViews.append(.newRecipient)
        }
        self.toggleViews(openedViews)
        self.view.endEditing(true)
    }
    
    func didChangeNewRecipientData(_ iban: String, name: String, alias: String) {
        self.presenter.didChangeNewRecipientData(iban, name: name, alias: alias)
    }
}

// MARK: - FullFavoritesListView Delegate
extension SendMoneyDestinationAccountViewController: SendMoneyDestinationAccountFullFavoritesListViewDelegate {
    func didSearchFavorite(text: String) {
        self.presenter.didSearchFavorite(text: text)
    }

    func didSelectFavorite(_ favorite: OneFavoriteContactCardViewModel) {
        self.presenter.didSelectFavoriteAccount(favorite, isFromList: true)
    }
    
    func didTapAddNewContact() {
        self.presenter.didTapAddNewContact()
    }
}

// MARK: - LastTransfersView Delegate
extension SendMoneyDestinationAccountViewController: SendMoneyDestinationAccountLastTransfersViewDelegate {
    func didSelectPastTransfer(index: Int) {
        self.presenter.didSelectPastTransfer(index: index)
    }
}

// MARK: - Keyboard Helper for FloatingButton

extension SendMoneyDestinationAccountViewController: FloatingButtonKeyboardHelper {
    @objc func keyboardWillShow(_ notification: Notification) {
        self.keyboardWillShowWithFloatingButton(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboardWillHideWithFloatingButton(notification)
    }
}

// MARK: Help tooltip

extension SendMoneyDestinationAccountViewController: BottomSheetViewProtocol {
    
    func didTapCloseButton() {
        UIAccessibility.post(notification: .layoutChanged, argument: self.ibanHelpView)
    }
}

extension SendMoneyDestinationAccountViewController: AccessibilityCapable {}

//MARK: - FloatingButtonLoaderCapable

extension SendMoneyDestinationAccountViewController: FloatingButtonLoaderCapable {
    var oneFloatingButton: OneFloatingButton {
        self.floatingButton
    }
}

extension SendMoneyDestinationAccountViewController: OneCheckboxViewDelegate {
    func didSelectOneCheckbox(_ isSelected: Bool) {
        self.newRecipientView.setFavoriteCheckBox(status: isSelected ? .activated : .inactive)
        self.presenter.didSelectOneCheckbox(isSelected)
    }
}

extension SendMoneyDestinationAccountViewController: SelectionListViewDelegate {
    func didSearchItem(_ searchItem: String) {
        self.presenter.didSearchCountry(searchItem)
    }
    
    func didSelectItem(_ item: String) {
        self.presenter.didSelectCountry(item)
        self.newRecipientView.reloadSpecialIBANForCountry()
    }
}

extension SendMoneyDestinationAccountViewController: NewRecipientAliasHelperViewDelegate {
    func aliasHelperDidTapButton() {
        self.closeBottomSheet()
    }
}
