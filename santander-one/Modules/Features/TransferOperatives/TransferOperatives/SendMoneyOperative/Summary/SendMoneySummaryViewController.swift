//
//  SendMoneySummaryViewController.swift
//  TransferOperatives
//
//  Created by Juan Diego Vázquez Moreno on 2/11/21.
//

import UIOneComponents
import Operative
import UI
import CoreFoundationLib
import UIKit

protocol SendMoneySummaryView: OperativeView, FloatingButtonLoaderCapable {
    func setHeader(_ state: SendMoneyTransferSummaryState)
    func setSummaryItems(_ items: [OneListFlowItemViewModel])
    func setTransferAmount(_ amount: NSAttributedString)
    func setSharingButtons(pdf: ShareButtonViewModel, image: ShareButtonViewModel)
    func setFooterViewModel(_ viewModel: OneFooterNextStepViewModel)
    func showFinancingViews()
    func showComingSoon()
    func addCostsWarningWith(labelValue: String?)
}

protocol SendMoneySummaryNationalSepaView: SendMoneySummaryView {}
protocol SendMoneySummaryNoSepaView: SendMoneySummaryView {}

class SendMoneySummaryViewController: UIViewController {

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
    @IBOutlet private weak var opinatorView: AnimatedOpinatorView!
    @IBOutlet private weak var financingButton: OneFloatingButton!
    @IBOutlet private weak var footerView: OneFooterNextStepView!
    @IBOutlet private weak var emptySpaceView: UIView?
    @IBOutlet private weak var amountRowStackView: UIStackView!
    
    let presenter: SendMoneySummaryPresenterProtocol
    var loadingView: UIView?
    
    init(presenter: SendMoneySummaryPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "SendMoneySummaryViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.presenter.viewDidLoad()
        self.setAccessibilityIdentifiers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }

    @IBAction func didTapOnToggleSummaryButton() {
        self.toggleSummaryButton.isSelected ? self.collapseSummary() : self.expandSummary()
        self.toggleSummaryButton.isSelected.toggle()
        self.presenter.didTapOnSeeSummary()
        self.updateAccessibilityIdentifiers()
    }
    
    @IBAction func didTapOnFinancingButton() {
        self.presenter.didTapOnFinancingButton()
    }
}

// MARK: - Private Logic
private extension SendMoneySummaryViewController {

    func configureViews() {
        self.configureScrollView()
        self.configureHeader()
        self.configureBody()
    }

    func configureScrollView() {
        self.scrollView.backgroundColor = .skyGray
        self.scrollView.delegate = self
    }

    func configureHeader() {
        self.successLabel.font = .typography(fontName: .oneH300Bold)
        self.successLabel.textColor = .oneLisboaGray
        self.successLabel.text = localized("summary_label_success")
        self.amountLabel.font = .typography(fontName: .oneB300Regular)
        self.amountLabel.textColor = .oneLisboaGray
        self.amountLabel.text = localized("summary_label_amountOf")
        self.moneyAmountLabel.textColor = .oneLisboaGray
        self.financingTagView.setup(titleKey: "summary_tag_financing")
        self.financingTagView.isHidden = true
        self.gradientView.setupType(.oneGrayGradient(direction: .bottomToTop))
        self.toggleSummaryButton.setBackgroundImage(Assets.image(named: "oneIcnOvalButtonDown"), for: .normal)
        self.toggleSummaryButton.setBackgroundImage(Assets.image(named: "oneIcnOvalButtonUp"), for: .selected)
        self.seeSummaryLabel.font = .typography(fontName: .oneB200Bold)
        self.seeSummaryLabel.textColor = .oneDarkTurquoise
        self.seeSummaryLabel.text = localized("summary_label_seeTheSummary")
        self.summaryStackView.isHidden = true
        self.emptySpaceView?.isHidden = self.summaryStackView.isHidden
    }

    func configureBody() {
        self.shareLabel.font = .typography(fontName: .oneH200Bold)
        self.shareLabel.textColor = .oneLisboaGray
        self.shareLabel.text = localized("sendMoney_label_shareSummary")
        self.opinatorView.setup(titleKey: "summary_label_recommend", onTapAction: self.presenter.didTapOnOpinatorView)
        let financingButtonTitle = localized(
            "summary_button_financingOptions",
            [StringPlaceholder(.value, self.presenter.transferAmount)]
        )
        let financingButtonConfig = OneFloatingButton.ButtonSize.MediumButtonConfig(
            title: financingButtonTitle.text,
            icons: .none,
            fullWidth: true
        )
        self.financingButton.configureWith(type: .secondary, size: .medium(financingButtonConfig), status: .ready)
        self.financingButton.isHidden = true
    }

    func setupNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setRightAction(.close, action: self.presenter.close)
            .build(on: self)
    }

    func expandSummary() {
        self.summaryStackView.isHidden = false
        self.seeSummaryLabel.isHidden = true
        self.emptySpaceView?.isHidden = self.summaryStackView.isHidden
        setAccessibilityForToggleButton()
        let firstView = self.summaryStackView.arrangedSubviews.first { $0 is OneListFlowItemView } as? OneListFlowItemView
        firstView?.setAccessibilityFocus()
    }

    func collapseSummary() {
        self.summaryStackView.isHidden = true
        self.seeSummaryLabel.isHidden = false
        self.emptySpaceView?.isHidden = self.summaryStackView.isHidden
        setAccessibilityForToggleButton()
    }

    func setAccessibilityIdentifiers() {
        self.rocketImageView.accessibilityIdentifier = AccessibilitySendMoneySummary.rocketImageView
        self.successLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.successLabel
        self.amountLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.amountLabel
        self.moneyAmountLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.moneyAmountLabel
        self.toggleSummaryButton.accessibilityIdentifier = AccessibilitySendMoneySummary.toggleSummaryButtonDown
        self.seeSummaryLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.seeSummaryLabel
        self.shareLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.shareLabel
        self.financingButton.accessibilityIdentifier = AccessibilitySendMoneySummary.financingButton
    }

    func updateAccessibilityIdentifiers() {
        self.toggleSummaryButton.accessibilityIdentifier = self.toggleSummaryButton.isSelected ?
            AccessibilitySendMoneySummary.toggleSummaryButtonUp :
            AccessibilitySendMoneySummary.toggleSummaryButtonUp
    }
    
    func setAccessibilityForSuccessSection() {
        self.seeSummaryLabel.isAccessibilityElement = false
        self.titleContainerView.accessibilityLabel = localized("voiceover_successTransferInfo").text
        self.amountLabel.accessibilityLabel = localized("summary_label_amountOf").text
    }
    
    func setAccessibilityForToggleButton() {
        self.toggleSummaryButton.accessibilityLabel = self.summaryStackView.isHidden ? localized("voiceover_button_seeTransfer").text : localized("voiceover_button_hideTransfer")
        self.toggleSummaryButton.accessibilityTraits = .button
        self.toggleSummaryButton.accessibilityHint = [localized("voiceover_tapTwiceTo"), (self.summaryStackView.isHidden ? localized("voiceover_open").text : localized("voiceover_close").text)].joined(separator:" ")
    }
    
    func setAccessibiityForShareSection() {
        self.shareLabel.isAccessibilityElement = true
        self.shareLabel.accessibilityLabel = localized("voiceover_shareSummaryTwoWays").text
        let pdfView = self.actionsStackView.arrangedSubviews.first
        let shareView = self.actionsStackView.arrangedSubviews.last
        pdfView?.isAccessibilityElement = true
        pdfView?.accessibilityLabel = localized("voiceover_downloadPdfPosition").text
        pdfView?.accessibilityTraits = .button
        shareView?.isAccessibilityElement = true
        shareView?.accessibilityLabel = localized("voiceover_shareImagePosition").text
        shareView?.accessibilityTraits = .button
    }
    
    func setAccessibilityForOpinatorSection() {
        opinatorView.isAccessibilityElement = true
        opinatorView.accessibilityLabel = localized("summary_label_recommend").text
        opinatorView.accessibilityTraits = .link
    }
    
    func setAccessibilityInfo() {
        self.successLabel.accessibilityTraits = .header
        UIAccessibility.post(notification: .screenChanged, argument: self.successLabel)
        setAccessibilityForSuccessSection()
        self.toggleSummaryButton.isAccessibilityElement = true
        setAccessibilityForToggleButton()
        setAccessibiityForShareSection()
        setAccessibilityForOpinatorSection()
    }
    
    func setAlternativeHeader(_ state: SendMoneyTransferSummaryState) {
        self.amountRowStackView.isHidden = true
        let imageName: String
        let tintColorImage: UIColor
        if case .pending(_,_) = state {
            imageName = "oneIcnClock"
            tintColorImage = .lightBrown
        } else {
            imageName = "oneIcnCircledError"
            tintColorImage = .bostonRed
        }
        self.alternativeResulImageView.image = Assets.image(named: imageName)?.withRenderingMode(.alwaysTemplate)
        self.alternativeResulImageView.tintColor = tintColorImage
        self.alternativeResulImageView.isHidden = false
        self.emptySpaceView?.removeFromSuperview()
        self.rocketImageView.isHidden = true
    }
}

// MARK: - Summary View Protocol
extension SendMoneySummaryViewController: SendMoneySummaryNationalSepaView, SendMoneySummaryNoSepaView {

    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
    
    func setHeader(_ state: SendMoneyTransferSummaryState) {
        let associatedValue = state.associatedValue()
        self.successLabel.configureText(withLocalizedString: localized(associatedValue.title ?? ""),
                                        andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.82))
        self.amountLabel.text = localized(associatedValue.subtitle ?? "")
        guard case .success = state else {
            self.setAlternativeHeader(state)
            return
        }
        self.rocketImageView.setRocketAnimation()
    }

    func setSummaryItems(_ items: [OneListFlowItemViewModel]) {
        items.forEach {
            let item = OneListFlowItemView()
            item.setupViewModel($0)
            self.summaryStackView.addArrangedSubview(item)
        }
    }

    func setTransferAmount(_ amount: NSAttributedString) {
        self.moneyAmountLabel.attributedText = amount
    }

    func setSharingButtons(pdf: ShareButtonViewModel, image: ShareButtonViewModel) {
        let pdfShareButton = ShareButtonView()
        pdfShareButton.setup(viewModel: pdf)
        self.actionsStackView.addArrangedSubview(pdfShareButton)
        let imageShareButton = ShareButtonView()
        imageShareButton.setup(viewModel: image)
        self.actionsStackView.addArrangedSubview(imageShareButton)
    }

    func setFooterViewModel(_ viewModel: OneFooterNextStepViewModel) {
        self.footerView.setViewModel(viewModel)
    }
    
    func showFinancingViews() {
        self.financingTagView.isHidden = false
        self.financingButton.isHidden = false
    }
    
    func showComingSoon() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func addCostsWarningWith(labelValue: String?) {
        guard let value = labelValue else { return }
        let alertView = OneAlertView()
        alertView.setType(.textAndImage(imageKey: "icnInfo", stringKey: value))
        self.summaryStackView.addArrangedSubview(alertView)
        let spacing = UIView()
        spacing.translatesAutoresizingMaskIntoConstraints = false
        spacing.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.summaryStackView.addArrangedSubview(spacing)
    }
}

extension SendMoneySummaryViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollView.backgroundColor = scrollView.contentOffset.y > 0 ? .blueAnthracita: .white
    }
}

extension SendMoneySummaryViewController: AccessibilityCapable {}

//MARK: - FloatingButtonLoaderCapable

extension SendMoneySummaryViewController {
    
    var oneFloatingButton: OneFloatingButton {
        return self.financingButton
    }
}
