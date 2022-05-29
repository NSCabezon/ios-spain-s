//
//  FractionablePurchaseCollectionViewCell.swift
//  Cards
//
//  Created by Ignacio González Miró on 31/5/21.
//

import CoreFoundationLib
import UI
import UIKit

protocol FractionablePurchaseCollectionViewCellDelegate: AnyObject {
    func resizeCell(_ model: FractionablePurchaseDetailViewModel)
}

final class FractionablePurchaseCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var tornImageView: UIImageView!
    @IBOutlet private weak var arrowImage: UIImageView!
    @IBOutlet private weak var expandOrCollapseButton: UIButton!
    @IBOutlet private weak var centerExpandableButtonConstraint: NSLayoutConstraint!
    @IBOutlet private weak var containerBottomHeightConstraint: NSLayoutConstraint!
    
    typealias CarouselConstants = FractionablePurchaseDetailCarouselConstants
    private var model: FractionablePurchaseDetailViewModel?
    weak var delegate: FractionablePurchaseCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        containerView.drawBorder(cornerRadius: 0, color: .mediumSkyGray, width: 1)
    }

    func setViewModel() -> FractionablePurchaseDetailViewModel? {
        return self.model
    }
    
    func configView(_ viewModel: FractionablePurchaseDetailViewModel) {
        self.model = viewModel
        removeArrangedSubviewsIfNeeded()
        setItemViews(viewModel)
        updateFooter()
    }

    @IBAction func didTapOnExpandOrCollapse(_ sender: Any) {
        guard let model = self.model else { return }
        delegate?.resizeCell(model)
    }
}

private extension FractionablePurchaseCollectionViewCell {
    // MARK: - Setup methods
    func setupView() {
        backgroundColor = .clear
        containerView.backgroundColor = .white
        tornImageView.image = Assets.image(named: "imgTornBig")
        self.arrowImage.image = Assets.image(named: "icnOvalArrowDown")
        setAccessibilityIds()
    }

    func setAccessibilityIds() {
        containerView.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.containerView
        expandOrCollapseButton.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.expandOrCollapseButton
        tornImageView.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.tornImageView
    }

    // MARK: - ConfigView methods
    func updateFooter() {
        setExpandableColapsableButton()
        setTornImageView()
        updateLayouts()
    }
    
    func setExpandableColapsableButton() {
        setImageButton()
        hiddesButtonIfNeeded()
    }
    
    func setImageButton() {
        guard let viewModel = self.model else {
            return
        }
        let buttonImage = viewModel.carouselState == .colapsed
            ? Assets.image(named: "icnOvalArrowDown")
            : Assets.image(named: "icnOvalArrowUp")
        self.arrowImage.image = buttonImage
    }
    
    func hiddesButtonIfNeeded() {
        guard let viewModel = self.model else {
            return
        }
        var isButtonHidden = false
        switch viewModel.carouselState {
        case .colapsed:
            switch viewModel.itemStatus {
            case .loading, .success:
                isButtonHidden = false
            case .error:
                isButtonHidden = true
            }
        case .expanded:
            isButtonHidden = false
        }
        arrowImage.isHidden = isButtonHidden
        expandOrCollapseButton.isHidden = isButtonHidden
    }
    
    func setTornImageView() {
        guard let viewModel = self.model else {
            return
        }
        var isTornImageHidden = false
        switch viewModel.carouselState {
        case .colapsed:
            isTornImageHidden = false
        case .expanded:
            isTornImageHidden = true
        }
        tornImageView.isHidden = isTornImageHidden
    }
    
    // MARK: - Config StackView
    func setItemViews(_ viewModel: FractionablePurchaseDetailViewModel) {
        switch viewModel.carouselState {
        case .colapsed:
            setCollapsedViews(viewModel)
        case .expanded:
            setExpandableViews(viewModel)
        }
    }
    
    func setCollapsedViews(_ viewModel: FractionablePurchaseDetailViewModel) {
        switch viewModel.itemStatus {
        case .loading:
            addCardDetail(viewModel)
            addLoadingView()
        case .success:
            addCardDetail(viewModel)
            addFeeDetail(viewModel)
        case .error:
            addCardDetail(viewModel)
            addFeeErrorView(viewModel)
        }
    }

    func setExpandableViews(_ viewModel: FractionablePurchaseDetailViewModel) {
        addCardDetail(viewModel)
        addFeeDetail(viewModel)
        addAmortizedView(viewModel)
        addOperationView(viewModel)
        addMoreInfoView(viewModel)
    }
    
    // MARK: - Arranged Subviews
    func addCardDetail(_ viewModel: FractionablePurchaseDetailViewModel) {
        let view = FractionablePurchaseDetailCardDetailView()
        view.configView(viewModel)
        self.stackView.addArrangedSubview(view)
    }

    func addFeeDetail(_ viewModel: FractionablePurchaseDetailViewModel) {
        let view = FractionablePurchaseDetailFeeDetailView()
        view.configView(viewModel)
        self.stackView.addArrangedSubview(view)
    }
    
    func addAmortizedView(_ viewModel: FractionablePurchaseDetailViewModel) {
        let view = FractionablePurchaseDetailAmortizedView()
        view.configView(viewModel)
        self.stackView.addArrangedSubview(view)
    }
    
    func addOperationView(_ viewModel: FractionablePurchaseDetailViewModel) {
        let view = FractionablePurchaseDetailOperationView()
        view.configView(viewModel)
        self.stackView.addArrangedSubview(view)
    }
    
    func addMoreInfoView(_ viewModel: FractionablePurchaseDetailViewModel) {
        let view = FractionablePurchaseDetailMoreInfoView()
        view.configView(viewModel)
        self.stackView.addArrangedSubview(view)
    }

    func addFeeErrorView(_ viewModel: FractionablePurchaseDetailViewModel) {
        let view = FractionablePurchaseDetailFeeErrorView()
        view.configView(viewModel)
        self.stackView.addArrangedSubview(view)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        if !stackView.arrangedSubviews.isEmpty {
            stackView.removeAllArrangedSubviews()
        }
    }

    func addLoadingView() {
        let view = FractionablePurchaseLoadingView()
        self.stackView.addArrangedSubview(view)
    }
    
    // MARK: - Update constraints
    func setContainerBottomHeightConstraint() {
        guard let viewModel = self.model else {
            return
        }
        switch viewModel.carouselState {
        case .colapsed:
            self.containerBottomHeightConstraint.constant = CarouselConstants.containerBottomDefaultHeightConstraint
        case .expanded:
            self.containerBottomHeightConstraint.constant = CarouselConstants.containerBottomUpdatedHeightConstraint
        }
    }
    
    func updateLayouts() {
        updateFooterConstraint()
        setContainerBottomHeightConstraint()
        self.layoutIfNeeded()
    }
    
    func updateFooterConstraint() {
        guard let viewModel = self.model else {
            return
        }
        var bottomHeight: CGFloat = 0
        switch viewModel.carouselState {
        case .colapsed:
            bottomHeight = CarouselConstants.centerExpandableButtonColapsedHeight
        case .expanded:
            bottomHeight = CarouselConstants.centerExpandableButtonExpandedHeight
        }
        centerExpandableButtonConstraint.constant = bottomHeight
    }
}
