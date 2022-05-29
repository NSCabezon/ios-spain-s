//
//  FundTransactionViewCell.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 30/3/22.
//

import Foundation
import CoreDomain

final class FundTransactionTableViewCellModel {
    var isOpened: Bool = false
    var movement: FundMovementRepresentable?
    var detail: FundMovementDetails?
}

final class FundTransactionTableViewCell: UITableViewCell {

    var model: FundTransactionTableViewCellModel?

    override func prepareForReuse() {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
    }

    func configure(withViewModel viewModel: FundMovements?, cellModel: FundTransactionTableViewCellModel?, viewController: FundTransactionsViewController?) {
        model = cellModel
        let fundMovementView = FundMovementView()
        fundMovementView.setViewModel(viewModel, andMovement: cellModel?.movement, andDetail: cellModel?.detail)
        if cellModel?.isOpened ?? false {
            fundMovementView.showMovementInfo()
        }
        fundMovementView.didSelectMovementDetail = { movement, fund in
            viewController?.selectedFundMovementView = fundMovementView
            viewController?.selectedCellModel = cellModel
            viewController?.didSelectMovementDetailSubject.send((movement: movement, fund: fund))
        }
        fundMovementView.didUpdateHeight = {
            viewController?.tableViewUpdate()
        }
        fundMovementView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fundMovementView)
        NSLayoutConstraint.activate([
            fundMovementView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            fundMovementView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            fundMovementView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            fundMovementView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
        self.selectionStyle = .none
        isAccessibilityElement = false
        accessibilityElements = [fundMovementView]
    }
}
