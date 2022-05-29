//
//  InternalTransferSummaryViewController.swift
//  Account
//
//  Created by crodrigueza on 4/3/22.
//

import UI
import OpenCombine
import CoreFoundationLib
import CoreDomain
import UIOneComponents

final class InternalTransferSummaryViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headerContainerView: UIView!
    @IBOutlet private weak var titleContainerView: UIView!
    @IBOutlet private weak var summaryStackView: UIStackView!
    @IBOutlet private weak var successLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var moneyAmountLabel: UILabel!
    @IBOutlet private weak var rocketImageView: UIImageView!
    @IBOutlet private weak var alternativeResulImageView: UIImageView!
    @IBOutlet private weak var financingTagView: OneTagView!
    @IBOutlet private weak var gradientView: OneGradientView!
    @IBOutlet private weak var seeSummaryLabel: UILabel!
    @IBOutlet private weak var toggleSummaryButton: UIButton!
    @IBOutlet private weak var shareLabel: UILabel!
    @IBOutlet private weak var actionsStackView: UIStackView!
    @IBOutlet private weak var financingButton: OneFloatingButton!
    @IBOutlet private weak var footerView: OneFooterNextStepView!
    @IBOutlet private weak var emptySpaceView: UIView?
    @IBOutlet private weak var amountRowStackView: UIStackView!
    private let viewModel: InternalTransferSummaryViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: InternalTransferSummaryDependenciesResolver

    init(dependencies: InternalTransferSummaryDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "InternalTransferSummaryViewController", bundle: .module)
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
    
    @IBAction func didTapOnToggleSummaryButton() {
        toggleSummaryButton.isSelected ? collapseSummary() : expandSummary()
        toggleSummaryButton.isSelected.toggle()
        updateAccessibilityIdentifiers()
        viewModel.didTapOnToggleSummaryButton()
    }
}

private extension InternalTransferSummaryViewController {
    func configureViews() {
        configureScrollView()
        configureHeader()
        configureBody()
    }

    func configureScrollView() {
        scrollView.backgroundColor = .skyGray
        scrollView.delegate = self
    }

    func configureHeader() {
        configureHeaderLabels()
        financingTagView.setup(titleKey: "summary_tag_financing")
        financingTagView.isHidden = true
        gradientView.setupType(.oneGrayGradient(direction: .bottomToTop))
        toggleSummaryButton.setBackgroundImage(Assets.image(named: "oneIcnOvalButtonDown"), for: .normal)
        toggleSummaryButton.setBackgroundImage(Assets.image(named: "oneIcnOvalButtonUp"), for: .selected)
        summaryStackView.isHidden = true
        emptySpaceView?.isHidden = summaryStackView.isHidden
    }
    
    func configureHeaderLabels() {
        successLabel.font = .typography(fontName: .oneH300Bold)
        successLabel.textColor = .oneLisboaGray
        successLabel.text = localized("summary_label_success")
        amountLabel.font = .typography(fontName: .oneB300Regular)
        amountLabel.textColor = .oneLisboaGray
        amountLabel.text = localized("summary_label_amountOf")
        moneyAmountLabel.textColor = .oneLisboaGray
        seeSummaryLabel.font = .typography(fontName: .oneB200Bold)
        seeSummaryLabel.textColor = .oneDarkTurquoise
        seeSummaryLabel.text = localized("summary_label_seeTheSummary")
    }

    func configureBody() {
        setShareLabel()
        setFinancingButton()
    }
    
    func setShareLabel() {
        shareLabel.font = .typography(fontName: .oneH200Bold)
        shareLabel.textColor = .oneLisboaGray
        shareLabel.text = localized("sendMoney_label_shareSummary")
    }
    
    func setFinancingButton() {
        let financingButtonTitle = localized(
            "summary_button_financingOptions",
            [StringPlaceholder(.value, "presenter.transferAmount")]
        )
        let financingButtonConfig = OneFloatingButton.ButtonSize.MediumButtonConfig(
            title: financingButtonTitle.text,
            icons: .none,
            fullWidth: true
        )
        financingButton.configureWith(type: .secondary,
                                      size: .medium(financingButtonConfig),
                                      status: .ready)
        financingButton.isHidden = true
    }

    func expandSummary() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.summaryStackView.isHidden = false
            self.seeSummaryLabel.isHidden = true
            self.emptySpaceView?.isHidden = self.summaryStackView.isHidden
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.summaryStackView.arrangedSubviews.forEach { view in view.isHidden = false }
            (self.summaryStackView.arrangedSubviews.first as? OneListFlowItemView)?.setAccessibilityFocus()
        }
    }

    func collapseSummary() {
        summaryStackView.arrangedSubviews.forEach { view in view.isHidden = true }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.summaryStackView.isHidden = true
            self.seeSummaryLabel.isHidden = false
            self.emptySpaceView?.isHidden = self.summaryStackView.isHidden
        }
    }

    func setAccessibilityIdentifiers() {
        rocketImageView.accessibilityIdentifier = AccessibilitySendMoneySummary.rocketImageView
        successLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.successLabel
        amountLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.amountLabel
        moneyAmountLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.moneyAmountLabel
        toggleSummaryButton.accessibilityIdentifier = AccessibilitySendMoneySummary.toggleSummaryButtonDown
        seeSummaryLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.seeSummaryLabel
        shareLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.shareLabel
        financingButton.accessibilityIdentifier = AccessibilitySendMoneySummary.financingButton
    }

    func updateAccessibilityIdentifiers() {
        toggleSummaryButton.accessibilityIdentifier = toggleSummaryButton.isSelected ?
            AccessibilitySendMoneySummary.toggleSummaryButtonUp :
            AccessibilitySendMoneySummary.toggleSummaryButtonUp
    }
    
    func setHeader(with amount: AmountRepresentable) {
        let decorator = AmountRepresentableDecorator(
            amount,
            font: .typography(fontName: .oneH500Bold),
            decimalFont: .typography(fontName: .oneH300Bold)
        )
        guard let formattedCurrency = decorator.getFormatedWithCurrencyName() else { return }
        moneyAmountLabel.attributedText = formattedCurrency
        successLabel.configureText(withLocalizedString: localized("summary_label_success"),
                                        andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.82))
        rocketImageView.setRocketAnimation()
    }
    
    func setSummaryItems(_ items: [OneListFlowItemViewModel]) {
        items.forEach {
            let item = OneListFlowItemView()
            item.setupViewModel($0)
            summaryStackView.addArrangedSubview(item)
        }
    }
    
    func setAlertItem(configuration: InternalTransferSummaryAdditionalFeeAlertConfiguration) {
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
        summaryStackView.addArrangedSubview(alert.embedIntoView(topMargin: 0, bottomMargin: 30, leftMargin: 0, rightMargin: 0))
    }

    func setSharingItems(_ items: [InternalTransferSummarySharingButtonItem]) {
        items.forEach {
            let sharingButtonView = InternalTransferSummarySharingButtonView(with: $0)
            actionsStackView.addArrangedSubview(sharingButtonView)
        }
    }
    
    func open(url: String) {
        
    }
}

private extension InternalTransferSummaryViewController {
    func bind() {
        bindHeader()
        bindSummary()
        bindAlertItem()
        bindSharing()
        bindFooter()
    }
    
    func bindHeader() {
        viewModel.state
            .case(InternalTransferSummaryState.headerLoaded)
            .sink { [weak self] amount in
                guard let self = self else { return }
                self.setHeader(with: amount)
            }
            .store(in: &subscriptions)
    }
    
    func bindSummary() {
        viewModel.state
            .case(InternalTransferSummaryState.summaryItemsLoaded)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.setSummaryItems(items)
            }
            .store(in: &subscriptions)
    }
    
    func bindAlertItem() {
        viewModel.state
            .case(InternalTransferSummaryState.alertItemLoaded)
            .sink { [weak self] configuration in
                guard let self = self else { return }
                self.setAlertItem(configuration: configuration)
            }
            .store(in: &subscriptions)
    }

    func bindSharing() {
        viewModel.state
            .case(InternalTransferSummaryState.sharingLoaded)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.setSharingItems(items)
            }
            .store(in: &subscriptions)
    }
    
    func bindFooter() {
        viewModel.state
            .case(InternalTransferSummaryState.footerLoaded)
            .sink { [weak self] item in
                guard let self = self else { return }
                self.footerView.setViewModel(item)
            }
            .store(in: &subscriptions)
    }
}

extension InternalTransferSummaryViewController: StepIdentifiable {}

extension InternalTransferSummaryViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollView.backgroundColor = scrollView.contentOffset.y > 0 ? .blueAnthracita: .white
    }
}
