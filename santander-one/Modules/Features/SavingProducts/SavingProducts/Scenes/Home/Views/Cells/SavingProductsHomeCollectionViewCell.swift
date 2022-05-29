import UI
import UIKit
import CoreFoundationLib
import OpenCombine

public enum DetailTitleLabelType: String {
    case balanceInclPending = "savingsHome_label_balancePending"
    case pending = "savingsHome_label_pending"
    case interestRate = "savingsHome_label_interestRate"
    case availableBalance = "savingsHome_label_availableBalance"
    case contributionsToDate = "savingsHome_label_contributionsToDate"
    case contributionsRemaining = "savingsHome_label_contributionsRemaining"
}

class SavingProductsHomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var savingProductsAccountIDLabel: UILabel!
    @IBOutlet weak private var savingProductsAccountIDButton: UIButton!
    @IBOutlet weak private var savingProductsLogoImageView: UIImageView!
    @IBOutlet weak private var savingProductsShareImageView: UIImageView!
    @IBOutlet weak private var savingProductsAliasLabel: UILabel!
    @IBOutlet weak private var savingProductsBalanceView: UIView!
    @IBOutlet weak private var savingProductsBalanceInfo: UILabel!
    @IBOutlet weak private var savingProductsBalanceLabel: UILabel!
    @IBOutlet weak private var savingProductsinformationImageView: UIImageView!
    @IBOutlet weak private var savingProductsInformationButton: UIButton!
    @IBOutlet weak private var savingProductsDataStackView: UIStackView!
    @IBOutlet weak private var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var stackViewIDBlankSpace: UILabel!
    private var model: Savings?
    private var didSelectShare: ((Savings) -> Void)?
    private var didSelectBalanceInfo: ((Savings) -> Void)?
    private var didSelectInterestInfo: (() -> Void)?
    private var didSelectInterestRateLink: ((Savings) -> Void)?
    private var isDetailCell: Bool?
    let copyIconTappedSubject = PassthroughSubject<Void, Never>()
    private var anySubscriptions: Set<AnyCancellable> = []

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.masksToBounds = true
        updateAdjacentCellColor()
        self.savingProductsAliasLabel.scaledFont = UIFont.santander(family: .headline, type: .bold, size: 18)
        self.savingProductsAccountIDLabel.scaledFont = UIFont.santander(family: .micro, type: .regular, size: 14)
        self.savingProductsBalanceInfo.scaledFont = UIFont.santander(family: .micro, type: .regular, size: 14)
        self.savingProductsBalanceInfo.text = localized("savings_label_currentBalance")
        self.savingProductsShareImageView.image = Assets.image(named: isDetailCell ?? false ? "icnCopyGreen" : "icnGrayShare")
        self.savingProductsShareImageView.changeImageTintColor(tintedWith: .darkTorquoise)
        self.savingProductsLogoImageView.image = Assets.image(named: "icnSantanderAccount")
        self.savingProductsinformationImageView .image = Assets.image(named: "oneIcnHelp")
        self.setAccessibilityIds()
    }
    
    func configure(withModel model: Savings, isDetailCell: Bool = false) {
        self.isDetailCell = isDetailCell
        handleDetailCellCustomizationAppearance()
        self.model = model
        self.savingProductsAliasLabel.text = model.alias
        self.savingProductsBalanceLabel.attributedText = model.decoratedAmount
        self.didSelectShare = model.didSelectShare
        self.didSelectBalanceInfo = model.didSelectBalanceInfo
        didSelectInterestInfo = model.didSelectInterestInfo
        self.didSelectInterestRateLink = model.didSelectInterestRateLink
        self.configureBalanceStack(model)
        self.handleIDExtraLine(model)
        self.containerView?.layoutIfNeeded()
        let placeholdersAmount = [StringPlaceholder(.value, model.amountAccessibility ?? "")]
        if UIAccessibility.isVoiceOverRunning {
            self.savingProductsBalanceInfo.accessibilityLabel = localized("voiceover_balance", placeholdersAmount).text
        }
    }

    override func prepareForReuse() {
        self.isDetailCell = nil
    }
    
    func getComplementaryDataHeight() -> CGFloat {
        return savingProductsDataStackView.frame.height
    }
    
    func updatePendingField(_ pendingField: String) {
        self.savingProductsDataStackView.subviews.forEach { (view) in
            let updatedview = view as? SavingsCollectionViewDetailsView
            if updatedview?.isPending  == true {
                updatedview?.loaderPendingView.isHidden = true
                updatedview?.detailValueLabel.text = pendingField
                let stringPlaceholders = [StringPlaceholder(.value, updatedview?.detailValueLabel.text ?? "")]
                updatedview?.accessibilityLabel = localized("voiceover_pendingBalance", stringPlaceholders).text
            }
        }
    }

    func handleTapableIconCopyDetailCell(_ isTappable: Bool) {
        guard let isDetailCell = isDetailCell,
              isDetailCell else {
            return
        }
        savingProductsAccountIDButton.isEnabled = isTappable
    }

    func updateAdjacentCellColor() {
        self.containerView.backgroundColor = UIColor.oneSkyGray
        self.contentView.layer.borderColor = UIColor.oneBrownGray.cgColor
    }
    
    func updateMainCellColor() {
        self.containerView.backgroundColor = UIColor.oneWhite
        self.contentView.layer.borderColor = UIColor.oneMediumSkyGray.cgColor
    }
    
    @IBAction func shareIdPressed(_ sender: Any) {
        if let isDetailCell = isDetailCell, isDetailCell {
            copyIconTappedSubject.send()
        }
        guard let viewModel = model else { return }
        didSelectShare?(viewModel)
    }
    
    @IBAction func balanceInformationPressed(_ sender: Any) {
        guard let viewModel = model else { return }
        didSelectBalanceInfo?(viewModel)
    }
}

private extension SavingProductsHomeCollectionViewCell {
    func configureBalanceStack(_ modelData: Savings) {
        self.savingProductsDataStackView.removeAllArrangedSubviews()
        self.addFields(modelData)
        self.addEmptyFields(modelData)
    }
    
    func addFields(_ model: Savings) {
        model.complementaryData.forEach { element in
            switch element {
            case .balanceInclPending:
                let balanceInclPending = SavingsCollectionViewDetailsView(detailTitleLabelText: DetailTitleLabelType.balanceInclPending.rawValue, detailValueLabelText: model.balanceInclPending ?? "--")
                let stringPlaceholders = [StringPlaceholder(.value, model.balanceInclPendingAccessibility ?? "")]
                balanceInclPending.isAccessibilityElement = UIAccessibility.isVoiceOverRunning
                balanceInclPending.accessibilityLabel = localized("voiceover_balanceIncludingPending", stringPlaceholders).text
                balanceInclPending.detailTitleLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
                balanceInclPending.detailTitleLabel.accessibilityIdentifier = "savingsHome_label_balancePending"
                balanceInclPending.detailValueLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
                balanceInclPending.detailValueLabel.accessibilityIdentifier = "savingProductLabelBalancePendingAmount"
                self.savingProductsDataStackView.addArrangedSubview(balanceInclPending)
            case .pending:
                let pending = SavingsCollectionViewDetailsView(detailTitleLabelText: DetailTitleLabelType.pending.rawValue,
                                                               detailValueLabelText: "-",
                                                               isPending:  true)
                let stringPlaceholders = [StringPlaceholder(.value, pending.detailValueLabel.text ?? "")]
                pending.isAccessibilityElement = UIAccessibility.isVoiceOverRunning
                pending.accessibilityLabel = localized("voiceover_pendingBalance", stringPlaceholders).text
                pending.detailTitleLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
                pending.detailTitleLabel.accessibilityIdentifier = "savingsHome_label_pending"
                pending.detailValueLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
                pending.detailValueLabel.accessibilityIdentifier = "savingProductLabelPendingAmount"
                self.savingProductsDataStackView.addArrangedSubview(pending)
            case .interestRate:
                let isDetail = isDetailCell ?? false
                let interestRateValue = model.interestRateLinkRepresentable?.title ?? model.interestRate ?? "--"
                let detailValueLabelFont = model.interestRateLinkRepresentable?.title == nil ? UIFont.typography(fontName: .oneB300Regular) : UIFont.typography(fontName: .oneB300Bold)
                let detailValuelabelFontColor = model.interestRateLinkRepresentable?.title == nil ? UIColor.brownishGray : UIColor.oneDarkTurquoise
                let interestRate = SavingsCollectionViewDetailsView(detailTitleLabelText: DetailTitleLabelType.interestRate.rawValue,
                                                                    detailValueLabelText: interestRateValue,
                                                                    detailValueLabelFont: detailValueLabelFont,
                                                                    detailValueLabelFontColor: detailValuelabelFontColor,
                                                                    withToolTip: isDetail)
                if isDetail {
                    bindInterestRateDetailsView(interestRate)
                }
                let stringPlaceholders = [StringPlaceholder(.value, interestRate.detailValueLabel.text ?? "")]
                interestRate.isAccessibilityElement = UIAccessibility.isVoiceOverRunning
                interestRate.accessibilityLabel = localized("voiceover_interestRate", stringPlaceholders).text
                interestRate.detailTitleLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
                interestRate.detailTitleLabel.accessibilityIdentifier = "savingsHome_label_interestRate"
                interestRate.detailValueLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
                interestRate.detailValueLabel.accessibilityIdentifier = model.interestRateLinkRepresentable?.title == nil ? "savingProductLabelInterestPercentage" : "generic_button_seeDetails"
				interestRate.detailValueLabelTapAction = {
                    model.didSelectInterestRateLink?(model)
                }
                self.savingProductsDataStackView.addArrangedSubview(interestRate)
            case .availableBalance:
                let availableBalance = SavingsCollectionViewDetailsView(detailTitleLabelText: DetailTitleLabelType.availableBalance.rawValue, detailValueLabelText: model.availableBalance ?? "--")
                let stringPlaceholders = [StringPlaceholder(.value, model.availableBalanceAccessibility ?? "")]
                availableBalance.isAccessibilityElement = UIAccessibility.isVoiceOverRunning
                availableBalance.accessibilityLabel = localized("voiceover_availableBalance", stringPlaceholders).text
                availableBalance.detailTitleLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
                availableBalance.detailTitleLabel.accessibilityIdentifier = "savingsHome_label_availableBalance"
                availableBalance.detailValueLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
                availableBalance.detailValueLabel.accessibilityIdentifier = "savingProductLabelAvailableBalanceAmount"
                self.savingProductsDataStackView.addArrangedSubview(availableBalance)
            case .contributionsToDate:
                let contributionsToDate = SavingsCollectionViewDetailsView(detailTitleLabelText: DetailTitleLabelType.contributionsToDate.rawValue, detailValueLabelText: "--")
                let stringPlaceholders = [StringPlaceholder(.value, contributionsToDate.detailValueLabel.text ?? "")]
                contributionsToDate.isAccessibilityElement = UIAccessibility.isVoiceOverRunning
                contributionsToDate.accessibilityLabel = localized("voiceover_contributionDate", stringPlaceholders).text
                contributionsToDate.detailTitleLabel.accessibilityIdentifier = "savingsHome_label_contributionsToDate"
                contributionsToDate.detailValueLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
                contributionsToDate.detailValueLabel.accessibilityIdentifier = "savingProductLabelContributionsDateAmount"
                self.savingProductsDataStackView.addArrangedSubview(contributionsToDate)
            case .contributionsRemaining:
                let contributionsRemaining = SavingsCollectionViewDetailsView(detailTitleLabelText: DetailTitleLabelType.contributionsRemaining.rawValue,
                                                                              detailValueLabelText: "--")
                let stringPlaceholders = [StringPlaceholder(.value, contributionsRemaining.detailValueLabel.text ?? "")]
                contributionsRemaining.isAccessibilityElement = UIAccessibility.isVoiceOverRunning
                contributionsRemaining.accessibilityLabel = localized("voiceover_contributionRemaining", stringPlaceholders).text
                contributionsRemaining.detailTitleLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
                contributionsRemaining.detailTitleLabel.accessibilityIdentifier = "savingsHome_label_contributionsRemaining"
                contributionsRemaining.detailValueLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
                contributionsRemaining.detailValueLabel.accessibilityIdentifier = "savingProductLabelContributionsRemainingAmount"
                self.savingProductsDataStackView.addArrangedSubview(contributionsRemaining)
            }
        }
    }
    
    func bindInterestRateDetailsView(_ detailView: SavingsCollectionViewDetailsView) {
        detailView.toolTipIconTappedSubject
            .sink { [unowned self] in
                self.didSelectInterestInfo?()
            }.store(in: &anySubscriptions)
    }
    
    func addEmptyFields(_ model: Savings) {
        let emptyFieldsToAdd = max((model.totalNumberOfFields - savingProductsDataStackView.arrangedSubviews.count), 0)
        for _ in 0..<emptyFieldsToAdd {
            let emptyField = SavingsCollectionViewDetailsView(detailTitleLabelText: "",
                                                                          detailValueLabelText: "")
            self.savingProductsDataStackView.addArrangedSubview(emptyField)
        }
    }
    
    func handleIDExtraLine(_ model: Savings) {
        self.savingProductsAccountIDLabel.text = model.idLabelForLengthReference
        let isReferenceTwoLines = self.savingProductsAccountIDLabel.intrinsicContentSize.width >= self.savingProductsAccountIDLabel.frame.maxX
        self.savingProductsAccountIDLabel.text = model.identification
        let isValueTwoLines = self.savingProductsAccountIDLabel.intrinsicContentSize.width >= self.savingProductsAccountIDLabel.frame.maxX
        self.stackViewIDBlankSpace.isHidden = (isReferenceTwoLines && !isValueTwoLines) ? false : true
    }

    func handleDetailCellCustomizationAppearance() {
        guard let isDetail = self.isDetailCell else { return }
        savingProductsShareImageView.image = Assets.image(named: isDetail ? "icnCopyGreen" : "icnGrayShare")
        savingProductsShareImageView.changeImageTintColor(tintedWith: .darkTorquoise)
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = "savingsProductViewItem"
        self.accessibilityElements = [contentView,
                                      savingProductsAliasLabel as Any,
                                      savingProductsLogoImageView as Any,
                                      savingProductsAccountIDLabel as Any,
                                      savingProductsAccountIDButton as Any,
                                      savingProductsBalanceInfo as Any,
                                      savingProductsInformationButton as Any,
                                      savingProductsDataStackView as Any]
        self.savingProductsAccountIDButton.accessibilityLabel = localized("voiceover_shareIdNumber")
        self.savingProductsAccountIDButton.accessibilityIdentifier = "savingProductShareIdBtn"
        self.savingProductsAliasLabel?.accessibilityIdentifier = "savingProductLabelAlias"
        self.savingProductsLogoImageView?.accessibilityIdentifier = "oneIcnSantanderAccount"
        self.savingProductsLogoImageView.accessibilityLabel = localized("voiceover_bankLogo_es_0049")
        self.savingProductsLogoImageView.isAccessibilityElement = true
        self.savingProductsAccountIDLabel.accessibilityIdentifier = "savingProductLabelNumber"
        self.savingProductsShareImageView.accessibilityIdentifier = "oneIcnShareNumber"
        self.savingProductsInformationButton.accessibilityLabel = localized("voiceover_howBalanceCalculated")
        self.savingProductsInformationButton.accessibilityIdentifier = "savingProductBalanceInfoBtn"
        self.savingProductsinformationImageView?.accessibilityIdentifier = "oneIcnHelp"
        self.savingProductsBalanceInfo.isAccessibilityElement = true
        self.savingProductsBalanceInfo.accessibilityIdentifier = "savingsHome_label_balance"
        self.savingProductsBalanceLabel.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
        self.savingProductsBalanceLabel?.accessibilityIdentifier = "savingProductLabelAmount"
    }
}
