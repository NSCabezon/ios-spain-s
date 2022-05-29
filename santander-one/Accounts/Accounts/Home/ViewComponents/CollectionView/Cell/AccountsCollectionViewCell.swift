//
//  AccountsCollectionViewCell.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import UIKit
import UI
import CoreFoundationLib

class AccountsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var aliasLabel: UILabel!
    @IBOutlet weak private var logoImageView: UIImageView!
    @IBOutlet weak private var ibanLabel: UILabel!
    @IBOutlet weak private var shareImageView: UIImageView!
    @IBOutlet weak private var shareButton: UIButton!
    @IBOutlet weak private var availableAmountDescription: UILabel!
    @IBOutlet weak private var informationImageView: UIImageView!
    @IBOutlet weak private var informationButton: UIButton!
    @IBOutlet weak private var availableAmount: UILabel!
    @IBOutlet weak private var currentAmountDescriptionLabel: UILabel!
    @IBOutlet weak private var currentAmountLabel: UILabel!
    @IBOutlet weak private var withHoldingView: UIView!
    @IBOutlet weak private var amountWithheldDescriptionLabel: UILabel!
    @IBOutlet weak private var amountWithheldLabel: UILabel!
    @IBOutlet weak private var arrowImageVeiw: UIImageView!
    @IBOutlet weak private var ownershipLabel: UILabel!
    @IBOutlet weak private var ownershipView: UIView!
    @IBOutlet weak private var loadingImageView: UIImageView!
    @IBOutlet weak private var withholdingButton: UIButton!
    @IBOutlet weak private var arrowImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var overdraftView: UIView!
    @IBOutlet weak private var overdraftAmountDescriptionLabel: UILabel!
    @IBOutlet weak private var overdraftAmountLabel: UILabel!
    @IBOutlet weak private var earningsAmountDescriptionLabel: UILabel!
    @IBOutlet weak private var earningsAmountLabel: UILabel!
    private var viewModel: AccountViewModel?
    weak var delegate: AccountsCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
        self.setAccessibilityIdentifiers()
        self.setAccessibilityLabels()
        self.groupAccessibilityElements()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.loadingImageView.setPointsLoader()
    }
    
    public func showLoading() {
        hideWithholding(true)
        self.loadingImageView.isHidden = false
        self.loadingImageView.setPointsLoader()
    }
    
    public func hideLoading() {
        if viewModel?.withholdingAmountAttributedString != nil {
            hideWithholding(false)
        }
        self.loadingImageView.isHidden = true
        self.loadingImageView.removeLoader()
    }
    
    func setWithholdingViewModel(_ viewModel: AccountViewModel?) {
        if let viewModel = viewModel, viewModel.withholdingAmountAttributedString != nil {
            self.amountWithheldLabel.attributedText = viewModel.withholdingAmountAttributedString
        } else {
            self.hideLoading()
            self.hideWithholding(true)
        }
    }
}

extension AccountsCollectionViewCell: AccountsCollectionViewCellProtocol {
    func configure(_ viewModel: AccountViewModel) {
        self.viewModel = viewModel
        self.aliasLabel.text = viewModel.alias
        self.ibanLabel.text = viewModel.ibanPapel
        self.availableAmount.attributedText = viewModel.availableBigAmountAttributedString
        self.currentAmountLabel.attributedText = viewModel.balanceAmountAttributedString
        self.setOwnership(viewModel)
        self.setDetailInfo(for: viewModel)
        self.setupViews(for: viewModel)
    }
}

private extension AccountsCollectionViewCell {
    enum ConstantAccountsCollectionViewCell {
        static let containerBorderWith: CGFloat = 1.0
        static let ownershipViewCornerRadius: CGFloat = 2.0
        static let ownershipViewBorderWidth: CGFloat = 1.0
    }
    
    func configureView() {
        let fontSantanderCommon: UIFont = .santander(family: .text, type: .regular, size: 14.0)
        let localizedConfigLeft = LocalizedStylableTextConfiguration(font: fontSantanderCommon, alignment: .left)
        let localizedConfigRight = LocalizedStylableTextConfiguration(font: fontSantanderCommon, alignment: .right)
        self.configureImagesAndContainer()
        self.configureLabels(fontSantanderCommon, localizedConfig: localizedConfigLeft)
        self.configureAmountWithhold(localizedConfigRight)
        self.configureOwnership()
        self.configureOverdraft(fontSantanderCommon)
        self.configureEarnings(fontSantanderCommon)
    }
    
    func configureImagesAndContainer() {
        self.containerView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.containerView.layer.borderWidth = ConstantAccountsCollectionViewCell.containerBorderWith
        self.logoImageView.isHidden = true
        self.shareImageView.image = Assets.image(named: "icnGrayShare")
        self.informationImageView.image = Assets.image(named: "icnInfoRedLight")
    }
    
    func configureLabels(_ commonFont: UIFont, localizedConfig: LocalizedStylableTextConfiguration) {
        self.aliasLabel.font = .santander(family: .text, type: .bold, size: 18.0)
        self.aliasLabel.textColor = .lisboaGray
        self.ibanLabel.font = commonFont
        self.ibanLabel.textColor = .grafite
        self.availableAmountDescription.configureText(
            withKey: "accountHome_label_availableBalance",
            andConfiguration: localizedConfig)
        self.availableAmountDescription.textColor = .grafite
        self.currentAmountDescriptionLabel.configureText(
            withKey: "accountHome_label_realBalance",
            andConfiguration: localizedConfig)
        self.currentAmountLabel.textColor = .lisboaGray
    }
    
    func configureAmountWithhold(_ localizedConfig: LocalizedStylableTextConfiguration) {
        self.amountWithheldDescriptionLabel.configureText(
            withKey: "accountHome_label_withholding",
            andConfiguration: localizedConfig)
        self.amountWithheldDescriptionLabel.textColor = .grafite
        self.amountWithheldLabel.textColor = .darkTorquoise
        self.amountWithheldLabel.textAlignment = .right
        self.arrowImageVeiw.image = Assets.image(named: "icnArrowRightGreen")
    }
    
    func configureOwnership() {
        self.ownershipLabel.font = .santander(family: .text, type: .bold, size: 10.0)
        self.ownershipLabel.textColor = .coolGray
        self.ownershipView.layer.cornerRadius = ConstantAccountsCollectionViewCell.ownershipViewCornerRadius
        self.ownershipView.layer.borderWidth = ConstantAccountsCollectionViewCell.ownershipViewBorderWidth
        self.ownershipView.layer.borderColor = UIColor.coolGray.cgColor
        self.ownershipView.backgroundColor = .clear
    }
    
    func configureOverdraft(_ fontSantanderCommon: UIFont) {
        self.overdraftAmountDescriptionLabel.font = fontSantanderCommon
        self.overdraftAmountDescriptionLabel.textColor = .grafite
        self.overdraftAmountLabel.font = fontSantanderCommon
        self.overdraftAmountLabel.textColor = .lisboaGray
    }
    
    func configureEarnings(_ fontSantanderCommon: UIFont) {
        self.earningsAmountDescriptionLabel.font = fontSantanderCommon
        self.earningsAmountDescriptionLabel.textColor = .grafite
        self.earningsAmountLabel.font = fontSantanderCommon
        self.earningsAmountLabel.textColor = .lisboaGray
    }
    
    func setDetailInfo(for viewModel: AccountViewModel) {
        self.viewModel = viewModel
        self.setWithholdingViewModel(viewModel)
    }
    
    func setupViews(for viewModel: AccountViewModel) {
        if self.viewModel?.detail != nil {
            self.hideLoading()
            self.hideDetailViews(false)
        } else {
            if self.viewModel?.isEnabledWithholdings ?? false {
                self.showLoading()
            }
            self.hideDetailViews(true)
        }
        self.setupOverdraftView()
        self.setupEarningView()
    }
    
    func setupOverdraftView() {
        guard let attributtedString = self.viewModel?.overdraftAmountAttributedString else { return }
        self.overdraftAmountDescriptionLabel.configureText(withKey: "accountHome_label_overdraft")
        self.overdraftAmountLabel.attributedText = attributtedString
    }
    
    func setupEarningView() {
        guard let attributtedString = self.viewModel?.earningsAmountAttributedString else { return }
        self.earningsAmountDescriptionLabel.configureText(withKey: "accountHome_label_realBalance")
        self.earningsAmountLabel.attributedText = attributtedString
    }
    
    func hideDetailViews(_ hide: Bool) {
        // Hidden until we can merge the epic with new design
        self.overdraftView.isHidden = true
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "accountHomeViewAccountData"
        aliasLabel.accessibilityIdentifier = "accountsHomeLabelAlias"
        ibanLabel.accessibilityIdentifier = "accountsHomeLabelIban"
        shareImageView.accessibilityIdentifier = "icnGrayShare"
        shareButton.accessibilityIdentifier = "icnShare"
        availableAmountDescription.accessibilityIdentifier = "accountHome_label_availableBalance"
        informationImageView.accessibilityIdentifier = "icnInfoRedLight"
        informationButton.accessibilityIdentifier = "icnInfo"
        availableAmount.accessibilityIdentifier = "accountsHomeLabelAvailableAmount"
        currentAmountDescriptionLabel.accessibilityIdentifier = "accountHome_label_realBalance"
        currentAmountLabel.accessibilityIdentifier = "accountsHomeLabelCurrentAmount"
        amountWithheldDescriptionLabel.accessibilityIdentifier = "accountHome_label_withholding"
        amountWithheldLabel.accessibilityIdentifier = "accountsHomeLabelWithheldAmount"
        arrowImageVeiw.accessibilityIdentifier = "icnArrowRight"
        ownershipLabel.accessibilityIdentifier = "accountsHomeLabelOwnership"
        ownershipView.accessibilityIdentifier = "accountsHomeViewOwnershipLabelContainer"
        loadingImageView.accessibilityIdentifier = "accountsHomeViewWithheldAmountLoading"
        withholdingButton.accessibilityIdentifier = "accountsHomeBtnWithheldAmount"
        self.logoImageView.accessibilityIdentifier = "icnSantanderAccount"
        self.overdraftAmountDescriptionLabel.accessibilityIdentifier = "accountHome_label_overdraft"
        self.overdraftAmountLabel.accessibilityIdentifier = "accountsHomeLabelOverdraftAmount"
        self.earningsAmountDescriptionLabel.accessibilityIdentifier = "accountHome_label_realBalance"
        self.earningsAmountLabel.accessibilityIdentifier = "accountsHomeLabelEarningsAmount"
    }
    
    func setAccessibilityLabels() {
        shareButton.accessibilityLabel = localized(AccessibilityAccountsHome.buttonShare)
        informationButton.accessibilityLabel = localized(AccessibilityAccountsHome.tooltipButton)
    }
    
    func groupAccessibilityElements() {
        self.accessibilityElements = {
            var elements: [Any] = []
            elements.append(contentsOf: [aliasLabel,
                                         ibanLabel,
                                         shareButton,
                                         availableAmountDescription,
                                         informationButton,
                                         availableAmount,
                                         currentAmountDescriptionLabel,
                                         currentAmountLabel,
                                         amountWithheldDescriptionLabel,
                                         amountWithheldLabel,
                                         ownershipLabel,
                                         ownershipView,
                                         withholdingButton,
                                         logoImageView]
                                .compactMap { $0 })
            return elements
        }()
    }
    
    func hideWithholding(_ hide: Bool) {
        self.withHoldingView.isHidden = hide
        if self.viewModel?.detail?.arrowWithholdVisible == false {
            self.arrowImageWidthConstraint.constant = 0.0
            self.withholdingButton.isUserInteractionEnabled = false
            self.amountWithheldLabel.textColor = .lisboaGray
        }
    }
    
    func hideOwnership(_ hide: Bool) {
        self.ownershipLabel.isHidden = hide
        self.ownershipView.isHidden = hide
    }
    
    func setOwnership(_ viewModel: AccountViewModel?) {
        if let ownershipText = viewModel?.ownershipText {
            self.ownershipLabel.text = ownershipText
        } else {
            self.hideOwnership(true)
        }
    }
    
    @IBAction func didTapOnInformation(_ sender: UIButton) {
        let styledText: LocalizedStylableText = localized("tooltip_label_accountAvailableBalance")
        BubbleLabelView.startWith(associated: sender, localizedStyleText: styledText, position: .bottom, accessibilityID: AccessibilityToolTip.accountDetailTooltipAvailableBalance, labelAccessibilityID: AccessibilityToolTip.accountDetailTooltipAvailableBalanceLabel)
    }
    
    @IBAction func didTapOnArrow(_ sender: UIButton) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didTapOnWithHolding(viewModel)
    }

    @IBAction func didTapOnShared(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didTapOnShareViewModel(viewModel)
    }
}
