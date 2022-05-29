//
//  CardTransactionCollectionInfoView.swift
//  Cards
//
//  Created by Oscar R. Garrucho.
//  Linkedin: https://www.linkedin.com/in/oscar-garrucho/
//  Copyright © 2022 Oscar R. Garrucho. All rights reserved.
//

import UIKit
import UI

final class OldCardTransactionCollectionInfoView: XibView {
    
    @IBOutlet private weak var detailsStackView: UIStackView!
    
    let verticalSpace: CGFloat = 20.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configureView(_ viewModel: OldCardTransactionDetailViewModel) {
        detailsStackView.removeAllArrangedSubviews()
        viewModel.getConfiguration().map { config in
            let detail = TransactionDetailView()
            detail.setConfiguration(config)
            return detail
        }
        .forEach { detailsStackView.addArrangedSubview($0) }
    }
    
    func getHeight() -> CGFloat {
        let items = detailsStackView.arrangedSubviews.count
        let spacing = CGFloat(items - 1) * ExpandableConfig.detailSpacing
        
        return (CGFloat(items) * ExpandableConfig.stackViewItemHeight) + spacing + verticalSpace
    }
}

private extension OldCardTransactionCollectionInfoView {
    func setupView() {
        backgroundColor = .clear
    }
}
