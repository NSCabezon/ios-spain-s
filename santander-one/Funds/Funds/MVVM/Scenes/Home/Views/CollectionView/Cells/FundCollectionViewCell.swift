//
//  FundCollectionViewCell.swift
//  Funds
//
import UI
import UIKit
import CoreFoundationLib
import OpenCombine
import UIOneComponents

struct FundCollectionViewCellIdentifiers {
    var fundsBgCard: String?
    var fundsBgTag = AccessibilityIdFundCarouselCell.fundsBgTag.rawValue
    var fundsLabelTag = AccessibilityIdFundCarouselCell.fundsLabelTag.rawValue
    var fundsLabelCarrouselAlias = AccessibilityIdFundCarouselCell.fundsLabelCarrouselAlias.rawValue
    var fundsLabelFundNumber = AccessibilityIdFundCarouselCell.fundsLabelFundNumber.rawValue
    var fundsIconShare = AccessibilityIdFundCarouselCell.fundsIconShare.rawValue
    var fundsLabelTotalInvestment = AccessibilityIdFundCarouselCell.fundsLabelTotalInvestment.rawValue
    var fundsLabelCarrouselAmount = AccessibilityIdFundCarouselCell.fundsLabelCarrouselAmount.rawValue
    var fundsLabelProfitability = AccessibilityIdFundCarouselCell.fundsLabelProfitability.rawValue
    var fundsIconProfitability = AccessibilityIdFundCarouselCell.icnQuery.rawValue
    var fundsLabelProfitabilityIncrease = AccessibilityIdFundCarouselCell.fundsLabelProfitabilityIncrease.rawValue
    var fundsIconProfitabilityIncrease = AccessibilityIdFundCarouselCell.icnIncrease.rawValue
    var fundsLabelProfitabilityAmount = AccessibilityIdFundCarouselCell.fundsLabelProfitabilityAmount.rawValue
}

enum FundCellConstants {
    static let dataViewTopWithOwnerView: CGFloat = 14
    static let dataViewTopWithoutOwnerView: CGFloat = 4
}

class FundCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var ownerView: UIView!
    @IBOutlet private weak var ownerLabel: UILabel!
    @IBOutlet private weak var dataView: UIView!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var fundNumberLabel: UILabel!
    @IBOutlet private weak var shareView: UIView!
    @IBOutlet private weak var shareImageView: UIImageView!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var totalInvestmentLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var profitabilityView: UIView!
    @IBOutlet private weak var profitabilityLabel: UILabel!
    @IBOutlet private weak var profitabilityQueryView: UIView!
    @IBOutlet private weak var profitabilityQueryImageView: UIImageView!
    @IBOutlet private weak var profitabilityQueryButton: UIButton!
    @IBOutlet private weak var profitabilityPercentLabel: UILabel!
    @IBOutlet private weak var profitabilityPercentImageView: UIImageView!
    @IBOutlet private weak var profitabilityAmountLabel: UILabel!
    @IBOutlet private weak var dataViewTopConstraint: NSLayoutConstraint!
    private var viewModel: Fund?
    var didSelectShare: ((Fund) -> Void)?
    var didSelectProfitabilityTooltip: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
    }

    func configure(withViewModel viewModel: Fund) {
        self.viewModel = viewModel
        self.aliasLabel.text = viewModel.alias
        let fundAlias = StringPlaceholder(.value, viewModel.alias ?? "")
        let fundNumber = StringPlaceholder(.value, viewModel.number ?? "")
        self.fundNumberLabel.text = localized("funds_label_fundNumber", [fundNumber]).text
        self.totalInvestmentLabel.text = localized("funds_label_totalInvestment")
        self.amountLabel.attributedText = viewModel.amountBigAttributedString
        self.amountLabel.isAccessibilityElement = false
        self.setOwnerView()
        self.setShareButton()
        self.setProfitabilityData()
        self.setCellViewsAppeaeance()
        self.setAccessibility { [weak self] in
            self?.aliasLabel.accessibilityLabel = localized("funds_label_fundNumber", [fundAlias]).text
            self?.totalInvestmentLabel.accessibilityLabel = localized("funds_label_totalInvestment") + " " + (viewModel.amount ?? "")
            self?.shareButton.accessibilityLabel = localized("voiceover_shareIdNumber")
            self?.profitabilityQueryButton.accessibilityLabel = localized("voiceover_profitabilityHelpInfo")
        }
    }

    func setAccessibilityIds(_ ids: FundCollectionViewCellIdentifiers) {
        accessibilityIdentifier = ids.fundsBgCard
        ownerView.accessibilityIdentifier = ids.fundsBgTag
        ownerLabel.accessibilityIdentifier = ids.fundsLabelTag
        aliasLabel.accessibilityIdentifier = ids.fundsLabelCarrouselAlias
        fundNumberLabel.accessibilityIdentifier = ids.fundsLabelFundNumber
        shareButton.accessibilityIdentifier = ids.fundsIconShare
        shareButton.isAccessibilityElement = true
        shareButton.accessibilityTraits = .button
        totalInvestmentLabel.accessibilityIdentifier = ids.fundsLabelTotalInvestment
        amountLabel.accessibilityIdentifier = ids.fundsLabelCarrouselAmount
        profitabilityLabel.accessibilityIdentifier = ids.fundsLabelProfitability
        profitabilityQueryButton.accessibilityIdentifier = ids.fundsIconProfitability
        profitabilityQueryButton.isAccessibilityElement = true
        profitabilityQueryButton.accessibilityTraits = .button
        profitabilityPercentLabel.accessibilityIdentifier = ids.fundsLabelProfitabilityIncrease
        profitabilityPercentImageView.accessibilityIdentifier = ids.fundsIconProfitabilityIncrease
        profitabilityAmountLabel.accessibilityIdentifier = ids.fundsLabelProfitabilityAmount
    }

    @IBAction func shareButtonDidPressed(_ sender: UIButton) {
        guard let fund = self.viewModel else { return }
        self.didSelectShare?(fund)
    }
    
    @IBAction func profitabilityQueryButtonDidPressed(_ sender: UIButton) {
        self.didSelectProfitabilityTooltip?()
    }
}

private extension FundCollectionViewCell {
    func setAppearance() {
        self.setCellViewsAppeaeance()
        self.aliasLabel.textColor = UIColor.oneLisboaGray
        self.fundNumberLabel.textColor = UIColor.oneBrownishGray
        self.totalInvestmentLabel.textColor = UIColor.oneBrownishGray
        self.amountLabel.textColor = UIColor.oneLisboaGray
        self.profitabilityLabel.textColor = UIColor.oneBrownishGray
        self.profitabilityPercentLabel.textColor = UIColor.oneLisboaGray
        self.profitabilityAmountLabel.textColor = UIColor.oneLisboaGray
    }

    func setCellViewsAppeaeance() {
        self.setRoundCornerRadius(withRadius: 4, forView: self.ownerView)
        self.setRoundCornerRadius(withRadius: 8, forView: self.dataView)
    }

    func setRoundCornerRadius(withRadius radius: CGFloat, forView view: UIView) {
        view.layer.borderColor = self.isSelected ? UIColor.oneMediumSkyGray.cgColor : UIColor.oneBrownGray.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = radius
        view.backgroundColor = self.isSelected ? UIColor.oneWhite : UIColor.oneSkyGray
    }

    func setOwnerView() {
        let isOwnerViewEnabled = self.viewModel?.isOwnerViewEnabled ?? false
        self.ownerView.isHidden = !isOwnerViewEnabled
        self.ownerLabel.text = self.viewModel?.ownershipType
        self.dataViewTopConstraint.constant = isOwnerViewEnabled ? FundCellConstants.dataViewTopWithOwnerView : FundCellConstants.dataViewTopWithoutOwnerView
    }

    func setShareButton() {
        let isShareButtonEnabled = self.viewModel?.isShareButtonEnabled ?? false
        self.shareView.isHidden = !isShareButtonEnabled
        self.shareImageView.image = Assets.image(named: "icnShareSlimGreen")
    }

    func setProfitabilityData() {
        let isProfitabilityDataEnabled = self.viewModel?.isProfitabilityDataEnabled ?? false
        self.profitabilityView.isHidden = !isProfitabilityDataEnabled
        self.profitabilityLabel.text = localized("funds_title_profitability")
        setAccessibility { [weak self] in
            self?.profitabilityLabel.accessibilityLabel = localized("funds_title_profitability") + " " + (self?.viewModel?.profitabilityPercent ?? "") + (self?.viewModel?.profitabilityAmount ?? "")
        }
        self.profitabilityQueryImageView.image = Assets.image(named: "icnHelp")
        self.profitabilityPercentLabel.text = self.viewModel?.profitabilityPercent
        self.profitabilityPercentLabel.isAccessibilityElement = false
        self.profitabilityPercentImageView.image = self.getProfitabilityPercentImageView(for: self.viewModel?.fundRepresentable.profitabilityPercent ?? 0)
        self.profitabilityAmountLabel.text = self.viewModel?.profitabilityAmount
        self.profitabilityAmountLabel.isAccessibilityElement = false
    }

    func getProfitabilityPercentImageView(for percent: Decimal) -> UIImage? {
        var percentArrow: String
        switch percent {
        case ..<0:
            percentArrow = "icnDecrease"
        case 0:
            percentArrow = "icnArrowNeutro"
        default:
            percentArrow = "icnIncrease"
        }
        return UIImage(named: percentArrow, in: .module, compatibleWith: nil)
    }
}

extension FundCollectionViewCell: AccessibilityCapable {}
