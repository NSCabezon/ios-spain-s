//
//  SendMoneyAmountNoSepaViewController.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 25/1/22.
//

import UIKit
import Operative
import UIOneComponents
import CoreFoundationLib
import UI
import IQKeyboardManagerSwift

protocol SendMoneyAmountNoSepaView: OperativeView, FloatingButtonLoaderCapable, SendMoneyCurrencyHelperViewProtocol {
    func addAccountSelector(_ viewModel: OneAccountsSelectedCardViewModel)
    func addRecipientBankView(viewModel: RecipientBankViewModel)
    func addAmountDateView(viewModel: AmountAndDateViewModel)
    func loadAllCurrencies(listItems: [OneSmallSelectorListViewModel],
                           carouselItems: [OneSmallSelectorListViewModel])
    func setCurrencies(listItems: [OneSmallSelectorListViewModel],
                       carouselItems: [OneSmallSelectorListViewModel])
    func closeBottomSheet()
    func isEnabledFloattingButton(_ isEnabled: Bool)
}

final class SendMoneyAmountNoSepaViewController: UIViewController {

    let presenter: SendMoneyAmountNoSepaPresenterProtocol
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet weak var floatingButton: OneFloatingButton!
    @IBOutlet weak var floatingButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingContainerView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    
    private lazy var amountDateView: AmountAndDateView = {
        return AmountAndDateView()
    }()
    
    lazy var currenciesSelectionView: SelectionListView = {
        let currenciesSelectionView = SelectionListView()
        currenciesSelectionView.setSelectionType(.currencies)
        currenciesSelectionView.delegate = self
        currenciesSelectionView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        return currenciesSelectionView
    }()
    
    lazy var costsBottomSheetView: ExpensesSelectorView = {
        let costsBottomSheetView = ExpensesSelectorView()
        costsBottomSheetView.delegate = self
        return costsBottomSheetView
    }()
    
    var loadingView: UIView?
    
    init(presenter: SendMoneyAmountNoSepaPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "SendMoneyAmountNoSepaViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTap()
        self.configureFloattingButton()
        self.configureLoadingView()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.configureKeyboardListener()
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        IQKeyboardManager.shared.enable = true
    }
}

private extension SendMoneyAmountNoSepaViewController {
    func setupNavigationBar() {
        let stepInfo = self.getOperativeStep()
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_amountAndDate")
            .setAccessibilityTitleValue(value: localized("siri_voiceover_step", [.init(.number, stepInfo[0]),
                                                                                 .init(.number, stepInfo[1])]).text)
            .setLeftAction(.back, customAction: {
                self.presenter.didSelectBack()
            })
            .setRightAction(.help, action: {
                Toast.show(localized("generic_alert_notAvailableOperation"))
            })
            .setRightAction(.close, action: {
                self.presenter.didSelectClose()
            })
            .build(on: self)
    }
    
    func configureFloattingButton() {
        self.floatingButton.configureWith(
            type: .primary,
            size: .large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(title: localized("generic_button_continue"),
                                                            subtitle: self.presenter.getSubtitleInfo(),
                                                            icons: .right, fullWidth: false)),
            status: .ready)
        self.floatingButton.addTarget(self, action: #selector(floatingButtonDidPressed), for: .touchUpInside)
    }
    
    func getOperativeStep() -> [String] {
        let stepOfSteps = self.presenter.getStepOfSteps()
        let step = String(stepOfSteps[0])
        let total = String(stepOfSteps[1])
        return [step, total]
    }
    
    @objc func floatingButtonDidPressed() {
        guard self.floatingButton.isEnabled else { return }
        self.presenter.didSelectContinue()
    }
    
    func configureKeyboardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func configureTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SendMoneyAmountNoSepaViewController: SendMoneyAmountNoSepaView {
    var amountAndDescriptionView: SendMoneyAmountAndDescriptionViewProtocol {
        return self.amountDateView
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
    
    func addAccountSelector(_ viewModel: OneAccountsSelectedCardViewModel) {
        let oneAccountsSelectedCardView = OneAccountsSelectedCardView()
        let oneCardSelectedContainerView = UIView()
        oneCardSelectedContainerView.addSubview(oneAccountsSelectedCardView)
        oneAccountsSelectedCardView.fullFit()
        oneAccountsSelectedCardView.delegate = self
        oneAccountsSelectedCardView.setupAccountViewModel(viewModel)
        self.stackView.addArrangedSubview(oneCardSelectedContainerView)
    }
    
    func addRecipientBankView(viewModel: RecipientBankViewModel) {
        let recipientBankView = RecipientBankView()
        recipientBankView.setupViewModel(viewModel)
        recipientBankView.delegate = self
        self.stackView.addArrangedSubview(recipientBankView)
    }
    
    func addAmountDateView(viewModel: AmountAndDateViewModel) {
        self.costsBottomSheetView.setupViewModel(viewModel)
        self.amountDateView.setupViewModel(viewModel, bottomSheetView: self.currenciesSelectionView, costsBottomSheetView: self.costsBottomSheetView)
        self.amountDateView.delegate = self
        self.stackView.addArrangedSubview(self.amountDateView)
    }
    
    func isEnabledFloattingButton(_ isEnabled: Bool) {
        self.floatingButton.isEnabled = isEnabled
    }
}

extension SendMoneyAmountNoSepaViewController: OneAccountsSelectedCardDelegate {
    func didSelectOriginButton() {
        self.presenter.changeOriginAccount()
    }
    
    func didSelectDestinationButton() {
        self.presenter.changeDestinationAccount()
    }
}

extension SendMoneyAmountNoSepaViewController: FloatingButtonKeyboardHelper {
    @objc func keyboardWillShow(_ notification: Notification) {
        self.keyboardWillShowWithFloatingButton(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboardWillHideWithFloatingButton(notification)
    }
}

extension SendMoneyAmountNoSepaViewController: SelectionListViewDelegate {
    func didSearchItem(_ searchItem: String) {
        self.presenter.didSearchCurrency(searchItem)
    }
    
    func didSelectItem(_ item: String) {
        self.presenter.didSelectCurrency(item)
    }
}

extension SendMoneyAmountNoSepaViewController: RecipientBankViewDelegate {
    func saveRecipientBankViewOutput(_ output: RecipientBankViewOutput) {
        self.presenter.saveRecipientBankOutput(output)
    }
    
    func hasEdited(_ field: String?) {
        self.presenter.hasEdited(field)
    }
}

extension SendMoneyAmountNoSepaViewController: AmountAndDateViewDelegate {
    func didUpdateAmount(to amount: String) {
        self.presenter.saveAmount(amount)
    }
    
    func didUpdateDescription(to description: String?) {
        self.presenter.saveDescription(description)
    }
}

extension SendMoneyAmountNoSepaViewController: ExpensesSelectorDelegate {
    func didSelectExpense(_ expense: SendMoneyNoSepaExpensesProtocol, viewController: UIViewController?) {
        self.presenter.didSelectExpense(expense)
        viewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - FloatingButtonLoaderCapable

extension SendMoneyAmountNoSepaViewController {
    var oneFloatingButton: OneFloatingButton {
        self.floatingButton
    }
}
