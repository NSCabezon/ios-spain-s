//
//  FractionalPaymentsView.swift
//  Account
//
//  Created by Sergio Escalante Ordoñez on 15/12/21.
//

import Foundation
import CoreFoundationLib
import UI
import UIKit

protocol FractionalPaymentViewDelegate: AnyObject {
    func didSelectPaymentView(viewModel: FinanceableInfoViewModel.FractionalPaymentBoxViewModel)
}

final class FractionalPaymentsView: XibView {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var scrollableView: UIView!
    
    // MARK: Constants
    
    private let horizontalStackView = HorizontalScrollableStackView(frame: .zero)
    weak var delegate: FractionalPaymentViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setViewModel(_ model: FinanceableInfoViewModel.FractionalPaymentModel) {
        horizontalStackView.stackView.removeAllArrangedSubviews()
        for card in model.cards {
            let view = FractionalPaymentBox()
            view.set(card)
            view.delegate = self
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: 148).isActive = true
            horizontalStackView.addArrangedSubview(view)
        }
        horizontalStackView.layoutIfNeeded()
    }
}

private extension FractionalPaymentsView {
    
    func setup() {
        horizontalStackView.setSpacing(12)
        horizontalStackView.setup(with: scrollableView)
        horizontalStackView.stackView.isLayoutMarginsRelativeArrangement = true
        horizontalStackView.enableScrollPagging(true)
        if #available(iOS 11.0, *) {
            horizontalStackView.stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        } else {
            horizontalStackView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

extension FractionalPaymentsView: FractionalPaymentBoxViewDelegate {
    func didSelectPaymentBox(viewModel: FinanceableInfoViewModel.FractionalPaymentBoxViewModel) {
        delegate?.didSelectPaymentView(viewModel: viewModel)
    }
}
