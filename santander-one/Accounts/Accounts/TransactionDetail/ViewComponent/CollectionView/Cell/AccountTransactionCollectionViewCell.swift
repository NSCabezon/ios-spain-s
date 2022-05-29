//
//  TransactionCollectionViewCell.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 11/25/19.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib

protocol TransactionCollectionViewCellDelegate: AnyObject {
    func didSelectEasyPay(viewModel: AccountTransactionDetailViewModel)
    func didSelectOffer(viewModel: AccountTransactionDetailViewModel)
    func resizeCell()
}

class AccountTransactionCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var tornImageView: UIImageView!
    @IBOutlet private weak var arrowImage: UIImageView!
    @IBOutlet private weak var bottomBorderLineView: UIView!
    @IBOutlet private weak var conceptLabel: VerticalAlignLabel!
    @IBOutlet private weak var accountAliasLabel: UILabel!
    @IBOutlet private weak var operationDateTitleLabel: UILabel!
    @IBOutlet private weak var operationDateValueLabel: UILabel!
    @IBOutlet private weak var dateTitleLabel: UILabel!
    @IBOutlet private weak var dateValueLabel: UILabel!
    @IBOutlet private weak var detailStackView: UIStackView!
    @IBOutlet private weak var expandOrCollapsButton: UIButton!
    @IBOutlet private weak var easyPayButton: RightArrowButtton!
    @IBOutlet private weak var loadingImageView: UIImageView!
    @IBOutlet private weak var spaceToBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var offerView: UIView!
    @IBOutlet private weak var imageCategory: UIImageView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var amountLabelView: OneLabelHighlightedView!
    
    private var viewModel: AccountTransactionDetailViewModel?
    var detailView: TransactionDetailView?
    weak var resizableDelegate: ResizableStateDelegate?
    weak var delegate: TransactionCollectionViewCellDelegate?
    var state: ResizableState = .colapsed
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.state = .colapsed
        self.tornImageView.image = Assets.image(named: "imgTorn")
        self.setAppareance()
        self.hideLoading()
        self.hideExpandImage()
        self.setupViewForState()
        self.setAccessibilityIdentifier()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.state = .colapsed
        self.removeExtraInfo()
    }
    
    private func setAppareance() {
        self.containerView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.containerView.layer.borderWidth = 1
        self.containerView.backgroundColor = UIColor.white
        self.bottomBorderLineView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.bottomBorderLineView.layer.borderWidth = 1
        self.bottomView.backgroundColor = UIColor.skyGray
        let configuration = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .regular, size: 12.0),
            alignment: .left,
            lineHeightMultiple: 0.75,
            lineBreakMode: .byTruncatingTail)
        self.categoryLabel.configureText(withKey: "", andConfiguration: configuration)
        self.categoryLabel.textColor = .grafite
    }
    
    public func setAccessibilityIdentifier() {
        arrowImage.accessibilityIdentifier = AccessibilityAccountTransactionCell.arrowImageDown
        conceptLabel.accessibilityIdentifier = AccessibilityAccountTransactionCell.conceptLabel
        accountAliasLabel.accessibilityIdentifier = AccessibilityAccountTransactionCell.accountAliasLabel
        amountLabelView.accessibilityIdentifier = AccessibilityAccountTransactionCell.amountLabel
        operationDateTitleLabel.accessibilityIdentifier = AccessibilityAccountTransactionCell.operationDateTitleLabel
        operationDateValueLabel.accessibilityIdentifier = AccessibilityAccountTransactionCell.operationDateValueLabel
        dateTitleLabel.accessibilityIdentifier = AccessibilityAccountTransactionCell.dateTitleLabel
        dateValueLabel.accessibilityIdentifier = AccessibilityAccountTransactionCell.dateValueLabel
        expandOrCollapsButton.accessibilityIdentifier = AccessibilityAccountTransactionCell.expandOrCollapsButton
        easyPayButton.accessibilityIdentifier = AccessibilityAccountTransactionCell.easyPayButton
        loadingImageView.accessibilityIdentifier = AccessibilityAccountTransactionCell.loadingView
    }
    
    @IBAction func didTapOnExpandOrCollaps(_ sender: Any) {
        self.toggleState()
        self.setupViewForState()
        self.setDetailForState()
        self.resizableDelegate?.didStateChange(self.state)
    }
    
    private func setDetailForState() {
        switch self.state {
        case .expanded:
            guard let detailView = self.detailView else { return }
            detailView.isHidden = false
            self.detailStackView.addArrangedSubview(detailView)
        case .colapsed:
            self.detailView?.isHidden = true
            self.removeExtraInfo()
        }
    }
    
    private func setupViewForState() {
        switch self.state {
        case .colapsed:
            self.setupViewForCollapsedState()
        case .expanded:
            self.setupViewForExpandedState()
        }
    }
    
    private func showLoading() {
        self.loadingImageView.isHidden = false
        self.loadingImageView.setPointsLoader()
    }
    
    public func hideLoading() {
        self.loadingImageView.isHidden = true
        self.loadingImageView.removeLoader()
    }
    
    public func showExpandImage() {
        self.arrowImage.isHidden = false
        self.expandOrCollapsButton.isHidden = false
    }
    
    private func hideExpandImage() {
        self.arrowImage.isHidden = true
        self.expandOrCollapsButton.isHidden = true
    }
    
    private func setupViewForCollapsedState() {
        self.arrowImage.image = Assets.image(named: "icnOvalArrowDown")
        self.arrowImage.accessibilityIdentifier = AccessibilityAccountTransactionCell.arrowImageDown
        self.tornImageView.isHidden = false
        self.bottomBorderLineView.isHidden = true
    }
    
    private func setupViewForExpandedState() {
        self.arrowImage.image = Assets.image(named: "icnOvalArrowUp")
        self.arrowImage.accessibilityIdentifier = AccessibilityAccountTransactionCell.arrowImageUp
        self.tornImageView.isHidden = true
        self.bottomBorderLineView.isHidden = false
    }
    
    @IBAction func didTapOnFinancing(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectEasyPay(viewModel: viewModel)
    }
    func configure(_ viewModel: AccountTransactionDetailViewModel) {
        self.viewModel = viewModel
        if let categoryInformation = viewModel.category {
            self.categoryLabel.text = localized(categoryInformation.literalKey)
            self.imageCategory.image = Assets.image(named: categoryInformation.iconName)
        } else {
            self.categoryLabel.text = nil
            self.imageCategory.image = nil
        }
        self.accountAliasLabel.text = viewModel.accountAlias
        self.accountAliasLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.conceptLabel.text = viewModel.description
        self.amountLabelView.attributedText = viewModel.formattedAmount
        
        if let value = viewModel.amount.value, value > 0 {
            amountLabelView.style = .lightGreen
        } else {
            amountLabelView.style = .clear
        }
        
        self.operationDateTitleLabel.text = localized("transaction_label_operationDate")
        self.operationDateTitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
        self.operationDateValueLabel.text = viewModel.operationDate
        self.operationDateValueLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.dateTitleLabel.text = localized("transaction_label_valueDate")
        self.dateTitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
        self.dateValueLabel.text = viewModel.valueDate
        self.dateValueLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.easyPayButton.setTitle(localized("transaction_button_finance"), for: .normal)
        self.easyPayButton.isHidden = !viewModel.isEasyPayEnabled
        self.easyPayButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.addExtraInfo(viewModel)
        self.setupViews(for: viewModel)
    }
    
    private func addExtraInfo(_ viewModel: AccountTransactionDetailViewModel) {
        guard self.state == .colapsed else { return }
        self.removeExtraInfo()
        self.detailView = TransactionDetailView(viewModel: viewModel)
        self.detailView?.axis = .vertical
        self.detailView?.spacing = Constants.detailSpacing
    }
    
    private func setupViews(for viewModel: AccountTransactionDetailViewModel) {
        if viewModel.detail == nil, viewModel.error == nil {
            self.showLoading()
            self.hideExpandImage()
        } else {
            self.hideLoading()
            self.showExpandImage()
            self.setupViewForState()
        }
        self.addOffer(viewModel)
    }
    
    private func removeExtraInfo() {
        guard let viewToRemove = self.detailView else { return }
        self.detailStackView.removeArrangedSubview(viewToRemove)
        viewToRemove.removeFromSuperview()
    }
    
    private func addOffer(_ viewModel: AccountTransactionDetailViewModel) {
        self.offerView.subviews.forEach { $0.removeFromSuperview() }
        guard let offer = viewModel.offerEntity, let url = offer.banner?.url else { return }
        let bannerView = BannerView()
        bannerView.setImageUrl(url)
        bannerView.delegate = self
        bannerView.addAction { [weak self] in
            self?.delegate?.didSelectOffer(viewModel: viewModel)
        }
        self.offerView.addSubview(bannerView)
    }
    
    struct Constants {
        static let extraInfoSpacing: CGFloat = 5
        static let extraInfoLabelHeight: CGFloat = 18
        static let stackViewItemHeight: CGFloat = 40
        static let collapsedHeight: CGFloat = 200
        static let estimatedHeight: CGFloat = 252
        static let detailSpacing: CGFloat = 16
        static let bottomMargin: CGFloat = 10
        static let margin: CGFloat = 32
    }
}

extension AccountTransactionCollectionViewCell: BannerViewDelegate {
    func ratioToResize(_ ratio: CGFloat) {
        guard let viewModel = self.viewModel else { return }
        viewModel.offerRatio = ratio
        self.delegate?.resizeCell()
    }
}

extension AccountTransactionCollectionViewCell: ResizableStateDelegate {
    func didStateChange(_ state: ResizableState) {
        self.state = state
        self.setupViewForState()
        self.setDetailForState()
    }
}

extension AccountTransactionCollectionViewCell: Resizable {
    func toggleState() {
        switch self.state {
        case .colapsed:
            self.state = .expanded
        case .expanded:
            self.state = .colapsed
        }
    }
    
    func getExpandedHeight() -> CGFloat {
        guard let detailView = self.detailView else { return 0.0 }
        var textHeight: CGFloat = 0
        let width = self.detailStackView.frame.width
        let font = conceptLabel.font ?? UIFont.santander(family: .text, type: .bold, size: 18)
        detailView.arrangedSubviews.forEach { item in
           item.getAllSubviews().forEach {
               textHeight += (($0 as? UILabel)?.text?.height(withConstrainedWidth: width, font: font) ?? Constants.extraInfoLabelHeight)}
            }
        return textHeight + getCollapsedHeight() + Constants.bottomMargin
    }
    
    func getCollapsedHeight() -> CGFloat {
        let width = containerView.bounds.width - Constants.margin
        let font = conceptLabel.font ?? UIFont.santander(family: .text, type: .bold, size: 18)
        let text = conceptLabel.text ?? ""
        let textHeight = text.height(withConstrainedWidth: width, font: font)
        let collapsedHight = Constants.collapsedHeight + textHeight
        guard collapsedHight >= Constants.estimatedHeight else {
            return Constants.estimatedHeight
        }
        return collapsedHight
    }
    
    func getOfferHeight() -> CGFloat {
        guard viewModel?.offerEntity?.banner != nil, let ratio = viewModel?.offerRatio else { return 0.0 }
        return self.frame.size.width * ratio
    }
}
