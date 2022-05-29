//
//  TransactionCollectionViewCell.swift
//  Cards
//
//  Created by Oscar R. Garrucho.
//  Linkedin: https://www.linkedin.com/in/oscar-garrucho/
//  Copyright © 2022 Oscar R. Garrucho. All rights reserved.
//

import UIKit
import UI
import CoreFoundationLib

protocol TransactionCollectionViewCellDelegate: AnyObject {
    func didTapOnFractionate()
    func didSelectOffer(viewModel: OldCardTransactionDetailViewModel)
    func resizeCell()
}

class OldCardTransactionCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    
    private var viewModel: OldCardTransactionDetailViewModel?
    weak var delegate: TransactionCollectionViewCellDelegate?

    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.backgroundColor = .white
        view.setSpacing(0)
        view.setup(with: self.containerView)
        return view
    }()
    
    var state: ResizableState = .expanded
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hideLoadingIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hideFractionateButtonIfNeeded()
    }
    
    func configure(_ viewModel: OldCardTransactionDetailViewModel, showFractionateButton: Bool = false) {
        self.viewModel = viewModel
        scrollableStackView.getArrangedSubviews().forEach { $0.removeFromSuperview() }
        addDetailsView(viewModel, showFractionateButton: showFractionateButton)
        addInfoView(viewModel)
        addBannerViewIfNeeded(viewModel)
    }
    
    func hideLoadingIfNeeded() {
        scrollableStackView.getArrangedSubviews().forEach {
            if let view = $0 as? OldCardTransactionCollectionBannerView {
                view.hideLoading()
            }
        }
    }
    
    func hideFractionateButtonIfNeeded() {
        scrollableStackView.getArrangedSubviews().forEach {
            if let view = $0 as? OldCardTransactionCollectionDetailsView {
                view.hideFractionateButton()
            }
        }
    }
}

// MARK: - CardTransactionCollectionViewCell views

private extension OldCardTransactionCollectionViewCell {
    
    func addDetailsView(_ viewModel: OldCardTransactionDetailViewModel, showFractionateButton: Bool? = false) {
        let view = OldCardTransactionCollectionDetailsView()
        view.configureView(viewModel, showFractionateButton: showFractionateButton ?? false)
        view.setDelegate(delegate: self)
        scrollableStackView.addArrangedSubview(view)
    }
    
    func addInfoView(_ viewModel: OldCardTransactionDetailViewModel) {
        let view = OldCardTransactionCollectionInfoView()
        view.configureView(viewModel)
        scrollableStackView.addArrangedSubview(view)
    }
    
    func addBannerViewIfNeeded(_ viewModel: OldCardTransactionDetailViewModel) {
        guard viewModel.offerEntity?.banner != nil else { return }
        
        let view = OldCardTransactionCollectionBannerView()
        view.configureView(viewModel)
        view.setDelegate(delegate: self)
        scrollableStackView.addArrangedSubview(view)
    }
}

extension OldCardTransactionCollectionViewCell: Resizable {
    func toggleState() { }
    
    func getExpandedHeight() -> CGFloat {
        var stackHeight: CGFloat = 0
        
        scrollableStackView.getArrangedSubviews().forEach {
            if let view = $0 as? OldCardTransactionCollectionInfoView {
                stackHeight = view.getHeight()
            }
        }
        let collapsedHeight = getCollapsedHeight()
        var offerHeight = getOfferHeight()
        if offerHeight > 0 {
            offerHeight += ExpandableConfig.collectionViewBottomSpacing
        }
        return stackHeight + collapsedHeight + offerHeight
    }
    
    func getCollapsedHeight() -> CGFloat {
        var textHeight: CGFloat = 0
        
        scrollableStackView.getArrangedSubviews().forEach {
            if let view = $0 as? OldCardTransactionCollectionDetailsView {
                textHeight = view.getHeight()
            }
        }
        
        return ExpandableConfig.collectionViewTopSpacing + textHeight
    }
    
    func getOfferHeight() -> CGFloat {
        guard viewModel?.offerEntity?.banner != nil,
              let ratio = viewModel?.offerRatio else { return 0.0 }
        return frame.size.width * ratio
    }
}

// MARK: - CardTransactionCollectionDetailsViewDelegate

extension OldCardTransactionCollectionViewCell: CardTransactionCollectionDetailsViewDelegate {
    func didTapOnFractionate() {
        delegate?.didTapOnFractionate()
    }
}

// MARK: - CardTransactionCollectionBannerViewDelegate

extension OldCardTransactionCollectionViewCell: CardTransactionCollectionBannerViewDelegate {
    func didSelectOffer(viewModel: OldCardTransactionDetailViewModel) {
        delegate?.didSelectOffer(viewModel: viewModel)
    }
    
    func ratioToResize(_ ratio: CGFloat) {
        guard let viewModel = self.viewModel else { return }
        
        viewModel.offerRatio = ratio
        delegate?.resizeCell()
    }
    
    func resizeCell(_ ratio: CGFloat) {
        guard let viewModel = self.viewModel else { return }
        
        viewModel.offerRatio = ratio
        delegate?.resizeCell()
    }
}
