//
//  InternalTransferConfirmationViewController.swift
//  TransferOperatives
//
//  Created by Juan Sánchez Marín on 2/3/22.
//

import UI
import OpenCombine
import CoreFoundationLib
import CoreDomain
import UIOneComponents

final class InternalTransferConfirmationViewController: UIViewController {
    private let viewModel: InternalTransferConfirmationViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: InternalTransferConfirmationDependenciesResolver
    private var anySubscriptions: Set<AnyCancellable> = []

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var confirmTitleLabel: UILabel!
    @IBOutlet private weak var confirmValueLabel: UILabel!
    @IBOutlet private weak var floatingButton: OneFloatingButton!
    @IBOutlet private weak var footerView: OneGradientView!

    init(dependencies: InternalTransferConfirmationDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "InternalTransferConfirmationViewController", bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        bind()
        viewModel.viewDidLoad()
        setAccessibilityIdentifiers()
    }
}

// MARK: - View configuration
private extension InternalTransferConfirmationViewController {

    func configureViews() {
        confirmTitleLabel.font = .typography(fontName: .oneB300Regular)
        confirmTitleLabel.textColor = .oneLisboaGray
        confirmTitleLabel.text = localized("confirmation_label_confirmBankTransfer")
        configureFloatingButton()
        footerView.setupType(.oneGrayGradient())
    }

    func configureFloatingButton() {
        floatingButton.backgroundColor = .clear
        floatingButton.configureWith(
            type: .primary,
            size: .large(OneFloatingButton.ButtonSize.LargeButtonConfig(
                            title: localized("generic_button_confirm"),
                            subtitle: localized("generic_button_summary"),
                            icons: .right,
                            fullWidth: true)),
            status: .ready)
    }

    func setAccessibilityIdentifiers() {
        self.confirmTitleLabel.accessibilityIdentifier = AccessibilitySendMoneyConfirmation.confirmTitleLabel
        self.confirmValueLabel.accessibilityIdentifier = AccessibilitySendMoneyConfirmation.confirmValueLabel
    }

    @objc func floatingButtonDidPressed() {
        viewModel.sendConfirmation()
    }

    func setConfirmationItems(_ items: [OneListFlowItemViewModel]) {
        items.forEach {
            let item = OneListFlowItemView()
            item.setupViewModel($0)
            stackView.addArrangedSubview(item)
        }
    }
    
    func setTransferAmount(_ amount: AmountRepresentable) {
        let decorator = AmountRepresentableDecorator(
            amount,
            font: .typography(fontName: .oneH500Bold),
            decimalFont: .typography(fontName: .oneH300Bold)
        )
        guard let formattedCurrency = decorator.getFormatedWithCurrencyName() else { return }
        confirmValueLabel.attributedText = formattedCurrency
    }

    func setAlertItem(configuration: InternalTransferConfirmationAlertConfiguration) {
        let alert = OneAlertView()
        if let linkKey = configuration.additionalFeeLinkKey {
            alert.setType(.textImageAndLink(imageKey: configuration.additionalFeeIconKey,
                                            stringKey: configuration.additionalFeeKey,
                                            linkKey: linkKey))
        } else {
            alert.setType(.textAndImage(imageKey: configuration.additionalFeeIconKey,
                                        stringKey: configuration.additionalFeeKey))
        }
        alert.linkSubject.sink { [weak self] in
            guard let self = self else { return }
            guard let url = configuration.additionalFeeLink else { return }
            self.open(url: url)
        }.store(in: &subscriptions)
        stackView.addArrangedSubview(alert.embedIntoView(topMargin: 0, bottomMargin: 30, leftMargin: 0, rightMargin: 0))
    }

    func open(url: String) {

    }
}

// MARK: - Reactive functions
private extension InternalTransferConfirmationViewController {

    func bind() {
        bindDataLoad()
        bindSendConfirmation()
        bindFloatingButtonTouch()
    }
    
    func bindDataLoad() {
        viewModel.state
            .case (InternalTransferConfirmationState.loaded)
            .sink { [weak self] data in
                guard let self = self else { return }
                self.setConfirmationItems(data.flowItems)
                self.setTransferAmount(data.ammount)
                guard let alert = data.alert else { return }
                self.setAlertItem(configuration: alert)
            }.store(in: &subscriptions)
    }

    func bindSendConfirmation() {
        viewModel.state
            .case (InternalTransferConfirmationState.confirmation)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.next()
            }.store(in: &anySubscriptions)
    }
    
    func bindFloatingButtonTouch() {
        floatingButton.onTouchSubject
            .sink { [weak self] in
                guard let self = self else { return }
                self.floatingButtonDidPressed()
            }.store(in: &subscriptions)
    }
}

extension InternalTransferConfirmationViewController: StepIdentifiable {}
