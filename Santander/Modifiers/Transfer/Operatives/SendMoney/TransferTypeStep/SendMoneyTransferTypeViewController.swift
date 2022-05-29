//
//  SendMoneyTransferTypeViewController.swift
//  Santander
//
//  Created by Angel Abad Perez on 25/11/21.
//

import UI
import UIKit
import Operative
import UIOneComponents
import CoreFoundationLib

protocol SendMoneyTransferTypeView: OperativeView {
    func showLoadingView()
    func hideLoadingView()
    func showTransferTypes(viewModel: SendMoneyTransferTypeRadioButtonsContainerViewModel)
    func closeBottomSheetView()
    func selectTransferType(at index: Int)
}

class SendMoneyTransferTypeViewController: UIViewController {
    private enum Constants {
        static let nibName: String = "SendMoneyTransferTypeViewController"
        enum NavigationBar {
            static let titleKey: String = "toolbar_title_sendType"
        }
        enum MainStackView {
            static let margins = UIEdgeInsets(top: 20.0,
                                              left: 16.0,
                                              bottom: .zero,
                                              right: 16.0)
        }
        enum TitleLabel {
            static let textKey: String = "sendMoney_label_sentType"
            static let bottomSpace: CGFloat = 20.0
        }
        enum RadioButtonsContainer {
            static let bottomSpace: CGFloat = 16.0
        }
        enum BottomInfoLabel {
            static let textKey: String = "sendType_disclaimer_commissions"
        }
        enum ContinueButton {
            static let titleKey: String = "generic_button_continue"
        }
    }
    
    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var floatingButton: OneFloatingButton!
    
    let presenter: SendMoneyTransferTypePresenterProtocol
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = .zero
        titleLabel.font = .typography(fontName: .oneH100Bold)
        titleLabel.textColor = .oneLisboaGray
        titleLabel.configureText(withKey: Constants.TitleLabel.textKey)
        return titleLabel
    }()
    private lazy var radioButtonsContainer: SendMoneyTransferTypeRadioButtonsContainerView = {
        let radioButtonsContainer = SendMoneyTransferTypeRadioButtonsContainerView()
        radioButtonsContainer.delegate = self
        return radioButtonsContainer
    }()
    private lazy var bottomInfoLabel: UILabel = {
        let bottomInfoLabel = UILabel()
        bottomInfoLabel.numberOfLines = .zero
        bottomInfoLabel.font = .typography(fontName: .oneB200Regular)
        bottomInfoLabel.textColor = .oneLisboaGray
        bottomInfoLabel.configureText(withKey: Constants.BottomInfoLabel.textKey)
        return bottomInfoLabel
    }()
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.frame = UIApplication.shared.keyWindow?.frame ?? CGRect()
        UIApplication.shared.keyWindow?.addSubview(view)
        view.backgroundColor = .white
        view.alpha = 0.6
        view.isHidden = true
        return view
    }()
    
    init(presenter: SendMoneyTransferTypePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: Constants.nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupComponents()
        self.setupNavigationBar()
        self.setupStackView()
        self.setAccessibilityIdentifiers()
        self.presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
}

private extension SendMoneyTransferTypeViewController {
    func setupNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: Constants.NavigationBar.titleKey)
            .setLeftAction(.back, customAction: self.didTapBack)
            .setRightAction(.help) {
                Toast.show(localized("generic_alert_notAvailableOperation"))
            }
            .setRightAction(.close) {
                self.presenter.didSelectClose()
            }
            .build(on: self)
    }
    
    func didTapBack() {
        self.presenter.didSelectBack()
    }
    
    func setupComponents() {
        self.floatingButton.configureWith(
            type: OneFloatingButton.ButtonType.primary,
            size: OneFloatingButton.ButtonSize.large(
                OneFloatingButton.ButtonSize.LargeButtonConfig(title: localized(Constants.ContinueButton.titleKey),
                                                            subtitle: self.presenter.getSubtitleInfo(),
                                                            icons: .right, fullWidth: false)),
            status: OneFloatingButton.ButtonStatus.ready)
        self.floatingButton.isEnabled = true
        self.floatingButton.addTarget(self, action: #selector(floatingButtonDidPressed), for: .touchUpInside)
    }
    
    func setupStackView() {
        self.mainStackView.isLayoutMarginsRelativeArrangement = true
        self.mainStackView.layoutMargins = Constants.MainStackView.margins
        self.mainStackView.addArrangedSubview(self.titleLabel)
        self.addSpacingView(spacing: Constants.TitleLabel.bottomSpace)
        self.mainStackView.addArrangedSubview(self.radioButtonsContainer)
        self.addSpacingView(spacing: Constants.RadioButtonsContainer.bottomSpace)
        self.mainStackView.addArrangedSubview(self.bottomInfoLabel)
    }
    
    @objc func floatingButtonDidPressed() {
        self.presenter.didPressedFloatingButton()
    }
    
    func addSpacingView(spacing: CGFloat) {
        let spacingView = UIView()
        spacingView.backgroundColor = .clear
        spacingView.heightAnchor.constraint(equalToConstant: spacing).isActive = true
        self.mainStackView.addArrangedSubview(spacingView)
    }

    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = Constants.TitleLabel.textKey
        self.bottomInfoLabel.accessibilityIdentifier = Constants.BottomInfoLabel.textKey
    }
    
    func setAccessibilityInfo() {
        let stepInfo = self.getOperativeStep()
        self.floatingButton.accessibilityLabel = localized("voiceover_button_continueConfirmation", [StringPlaceholder(.number, stepInfo[0]),
                                                                                                     StringPlaceholder(.number, stepInfo[1])]).text
        self.floatingButton.accessibilityHint = self.floatingButton.isEnabled ? localized("voiceover_activated") : localized("voiceover_desactivated")
        UIAccessibility.post(notification: .layoutChanged, argument: self.navigationItem.titleView)
    }
    
    func getOperativeStep() -> [String] {
        let stepOfSteps = self.presenter.getStepOfSteps()
        let step = String(stepOfSteps[0])
        let total = String(stepOfSteps[1])
        return [step, total]
    }
}

extension SendMoneyTransferTypeViewController: SendMoneyTransferTypeView {
    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
    
    func showLoadingView() {
        self.loadingView.isHidden = false
        self.floatingButton.setLoadingStatus(.loading)
    }
    
    func hideLoadingView() {
        self.loadingView.isHidden = true
        self.floatingButton.setLoadingStatus(.ready)
    }
    
    func showTransferTypes(viewModel: SendMoneyTransferTypeRadioButtonsContainerViewModel) {
        self.radioButtonsContainer.setViewModel(viewModel)
    }
    
    func closeBottomSheetView() {
        self.presentedViewController?.dismiss(animated: true)
    }
    
    func selectTransferType(at index: Int) {
        self.radioButtonsContainer.selectItem(at: index)
    }
}

extension SendMoneyTransferTypeViewController: SendMoneyTransferTypeRadioButtonsContainerViewDelegate {
    func didSelectRadioButton(at index: Int) {
        self.presenter.didSelectTransferType(at: index)
    }
    
    func didSelectOptionFromCostView(at index: Int) {
        self.presenter.didSelectOptionFromCostView(at: index)
        UIAccessibility.post(notification: .layoutChanged, argument: self.floatingButton)
    }
    
    func didTapTooltip() {
        self.presenter.didTapTooltip()
    }
}

extension SendMoneyTransferTypeViewController: AccessibilityCapable {}
