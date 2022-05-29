//
//  SendMoneyAmountViewController.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 27/9/21.
//


import UIKit
import Operative
import UI
import UIOneComponents
import CoreFoundationLib
import IQKeyboardManagerSwift

protocol SendMoneyAmountView: OperativeView, FloatingButtonLoaderCapable, SendMoneyCurrencyHelperViewProtocol {
    func addAccountSelector(_ viewModel: OneAccountsSelectedCardViewModel)
    func addSendMoneyAmountAndDescriptionView(amount: Decimal?, description: String?, isCurrencyEditable: Bool, currencyCode: String?)
    func addSelectDateOneContainerView(_ viewModel: SelectDateOneContainerViewModel, isSelectDeadlineCheckbox: Bool, endDate: Date?)
    func isEnabledFloattingButton(_ isEnabled: Bool)
}

final class SendMoneyAmountViewController: UIViewController {
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet weak var floatingButton: OneFloatingButton!
    @IBOutlet weak var floatingButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var loadingContainerView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    
    let presenter: SendMoneyAmountPresenterProtocol
    private var timer: Timer?
    private let sendMoneyAndDescriptionView = SendMoneyAmountAndDescriptionView()
    private let selectDateOneContainerView = SelectDateOneContainerView()
    lazy var currenciesSelectionView: SelectionListView = {
        let currenciesSelectionView = SelectionListView()
        currenciesSelectionView.setSelectionType(.currencies)
        currenciesSelectionView.delegate = self
        currenciesSelectionView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        return currenciesSelectionView
    }()
    var loadingView: UIView?
    
    private struct Constants {
        static let maxCounterLabel: String = "140"
        static let actualCounterLabel = "0"
        static let floattingButtonBottom: CGFloat = 24
        static let floattingButtonBottomKeyboard: CGFloat = -10
        static let timeInterval = 2
    }
    
    init(presenter: SendMoneyAmountPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "SendMoneyAmountViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.viewDidAppear()
        self.setAccessibility(setViewAccessibility: self.setAccesibilityInfo)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTap()
        self.configureFloattingButton()
        self.configureLoadingView()
        self.presenter.viewDidLoad()
        let time = TimeInterval(Constants.timeInterval)
        self.startTimer(withTime: time)
        WindowWatcher.shared.add(subscriptor: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.configureKeyboardListener()
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        IQKeyboardManager.shared.enable = true
    }
}

extension SendMoneyAmountViewController: SendMoneyAmountView {
    var amountAndDescriptionView: SendMoneyAmountAndDescriptionViewProtocol {
        return self.sendMoneyAndDescriptionView
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
    
    func addAccountSelector(_ viewModel: OneAccountsSelectedCardViewModel) {
        let oneAccountsSelectedCardView = OneAccountsSelectedCardView()
        let oneCardSelectedContainerView = UIView()
        oneCardSelectedContainerView.addSubview(oneAccountsSelectedCardView)
        oneAccountsSelectedCardView.fullFit(leftMargin: 16, rightMargin: 16)
        oneAccountsSelectedCardView.delegate = self
        oneAccountsSelectedCardView.setupAccountViewModel(viewModel)
        oneAccountsSelectedCardView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.addArrangedSubview(oneCardSelectedContainerView)
    }
    
    func addSendMoneyAmountAndDescriptionView(amount: Decimal?, description: String?, isCurrencyEditable: Bool, currencyCode: String?) {
        self.sendMoneyAndDescriptionView.delegate = self
        self.sendMoneyAndDescriptionView.setDescriptionView(maxCounterLabel: Constants.maxCounterLabel, actualCounterLabel: Constants.actualCounterLabel)
        if let value = amount {
            self.sendMoneyAndDescriptionView.setAmount("\(String(describing: value))")
        }
        if let description = description {
            self.sendMoneyAndDescriptionView.setDescription(description)
        }
        self.saveAmountAndDescription(amount: self.sendMoneyAndDescriptionView.getAmount(), description: self.sendMoneyAndDescriptionView.getDescription())
        let sendMoneyAmountAndDescriptionContainerView = UIView()
        sendMoneyAmountAndDescriptionContainerView.addSubview(sendMoneyAndDescriptionView)
        sendMoneyAndDescriptionView.fullFit(topMargin: 24)
        self.sendMoneyAndDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        self.sendMoneyAndDescriptionView.setBottomSheet(isCurrencyEditable: isCurrencyEditable,
                                                        bottomSheetView: self.currenciesSelectionView,
                                                        currencyCode: currencyCode)
        self.stackView.addArrangedSubview(sendMoneyAmountAndDescriptionContainerView)
    }
    
    
    func isEnabledFloattingButton(_ isEnabled: Bool) {
        self.floatingButton.isEnabled = isEnabled
    }
    
    func addSelectDateOneContainerView(_ viewModel: SelectDateOneContainerViewModel, isSelectDeadlineCheckbox: Bool, endDate: Date?) {
        self.selectDateOneContainerView.delegate = self
        self.selectDateOneContainerView.setViewModels(viewModel, isSelectDeadlineCheckbox: isSelectDeadlineCheckbox, endDate: endDate)
        self.selectDateOneContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.addArrangedSubview(self.selectDateOneContainerView)
    }
}

private extension SendMoneyAmountViewController {
    
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
    
    func configureKeyboardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func startTimer(withTime time: TimeInterval) {
        self.timer = Timer.scheduledTimer(timeInterval: time,
                                          target: self,
                                          selector: #selector(selectAmount),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        WindowWatcher.shared.remove(subscriptor: self)
        self.timer = nil
    }
    
    @objc func selectAmount() {
        self.sendMoneyAndDescriptionView.textFieldFirstResponder()
    }
    
    func configureTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func floatingButtonDidPressed() {
        guard self.floatingButton.isEnabled else { return }
        self.presenter.didSelectContinue()
    }
    
    func setAccesibilityInfo() {
        let stepInfo = self.getOperativeStep()
        
        self.floatingButton.accessibilityLabel = localized("voiceover_button_continueTypeTransfer", [.init(.number, stepInfo[0]), .init(.number, stepInfo[1])]).text
        self.floatingButton.accessibilityHint = self.floatingButton.isEnabled ? localized("voiceover_activated") : localized("voiceover_deactivated")
        UIAccessibility.post(notification: .layoutChanged, argument: self.navigationItem.titleView)
    }
    
    func getOperativeStep() -> [String]{
        let stepOfSteps = self.presenter.getStepOfSteps()
        let step = String(stepOfSteps[0])
        let total = String(stepOfSteps[1])
        return [step, total]
    }
}

extension SendMoneyAmountViewController: OneAccountsSelectedCardDelegate {
    func didSelectOriginButton() {
        self.presenter.changeOriginAccount()
    }
    
    func didSelectDestinationButton() {
        self.presenter.changeDestinationAccount()
    }
}

extension SendMoneyAmountViewController: WindowWatcherSubscriptor {
    public func windowTouched() {
        if self.timer != nil {
            stopTimer()
        }
    }
}

extension SendMoneyAmountViewController: SendMoneyAmountAndDescriptionViewDelegate {
    func saveAmountAndDescription(amount: String, description: String?) {
        self.presenter.saveAmountAndDescription(amount: amount, description: description)
    }
}

extension SendMoneyAmountViewController: SelectDateOneContainerViewDelegate {
    func getSendMoneyPeriodicity(_ index: Int) -> SendMoneyPeriodicityTypeViewModel {
        return self.presenter.getSendMoneyPeriodicity(index)
    }
    
    func didSelecteOneFilterSegment(_ type: SendMoneyDateTypeViewModel) {
        self.presenter.didSelecteOneFilterSegment(type)
    }
    
    func didSelectStartDate(_ date: Date) {
        self.presenter.didSelectStartDate(date)
    }
    
    func didSelectEndDate(_ date: Date) {
        self.presenter.didSelectEndDate(date)
    }
    
    func didSelectDeadlineCheckbox(_ isDeadLine: Bool) {
        self.presenter.didSelectDeadlineCheckbox(isDeadLine)
    }
    
    func didSelectFrequency(_ type: SendMoneyPeriodicityTypeViewModel) {
        self.presenter.didSelectFrequency(type)
    }
    
    func didSelectBusinessDay(_ type: SendMoneyEmissionTypeViewModel) {
        self.presenter.didSelectBusinessDay(type)
        UIAccessibility.post(notification: .layoutChanged, argument: self.floatingButton)
    }
}

extension SendMoneyAmountViewController: IssueDateOneSelectDelegate {
    func didSelectIssueDate(_ date: Date) {
        self.presenter.didSelectIssueDate(date)
        UIAccessibility.post(notification: .layoutChanged, argument: self.floatingButton)
    }
}

extension SendMoneyAmountViewController: SelectionListViewDelegate {
    func didSearchItem(_ searchItem: String) {
        self.presenter.didSearchCurrency(searchItem)
    }
    
    func didSelectItem(_ item: String) {
        self.presenter.didSelectCurrency(item)
    }
}

// MARK: - Keyboard Helper for FloatingButton

extension SendMoneyAmountViewController: FloatingButtonKeyboardHelper {
    @objc func keyboardWillShow(_ notification: Notification) {
        self.keyboardWillShowWithFloatingButton(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboardWillHideWithFloatingButton(notification)
    }
}

//MARK: - FloatingButtonLoaderCapable

extension SendMoneyAmountViewController {
    var oneFloatingButton: OneFloatingButton {
        self.floatingButton
    }
}

extension SendMoneyAmountViewController: AccessibilityCapable {}
