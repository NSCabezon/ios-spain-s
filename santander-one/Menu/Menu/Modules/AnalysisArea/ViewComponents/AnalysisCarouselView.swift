//
//  AnalysisCarouselView.swift
//  Menu
//
//  Created by Laura González on 19/03/2020.
//

import Foundation
import UI
import CoreFoundationLib

class AnalysisCarouselView: UIDesignableView {
    
    // MARK: - Outlets
    @IBOutlet weak private var collectionView: AnalysisCarouselCollectionView!
    @IBOutlet weak private var tipStackView: UIStackView!
    @IBOutlet weak private var verticalSpacingConstraint: NSLayoutConstraint!
    
    private var viewModel: AnalysisCarouselViewModel?

    // MARK: - Public
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override public func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    public func updateData(_ viewModel: AnalysisCarouselViewModel) {
        self.viewModel = viewModel
    }
    
    func setViewModel(_ viewModel: AnalysisCarouselViewModel, delegateBudget: CreateBudgetCollectionViewCellDelegate?, delegateBudgetCell: AnalysisCarouselCollectionViewCellDelegate?) {
        self.collectionView.setViewModel(viewModel, delegateBudget: delegateBudget, delegateBudgetCell: delegateBudgetCell)
    }
    
    public func showFinancialBudgetTip(_ offer: OfferCustomTipViewModel, action : (() -> Void)?) {
        let view = OfferCustomTipView(frame: .zero)
        view.configView(offer, action: action)
        tipStackView.removeAllArrangedSubviews()
        verticalSpacingConstraint.constant = 16
        tipStackView.addArrangedSubview(view)
    }
    
    public func hideFinancialBudgetTip() {
        verticalSpacingConstraint.constant = 0
        tipStackView.removeAllArrangedSubviews()
    }
    
    func moveBudgetCell(completion: @escaping (() -> Void)) {
        let row = self.collectionView.numberOfItems(inSection: 0) - 1
        guard row > 0 else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .centeredHorizontally, animated: false)
        }, completion: { _ in
            completion()
        })
    }
}

// MARK: - Private

private extension AnalysisCarouselView {
    func setupView() {
        collectionView.backgroundColor = .clear
    }
}
