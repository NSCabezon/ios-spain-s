//
//  FractionatedPaymentView.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 7/3/20.
//

import Foundation
import CoreFoundationLib

public final class FractionatedPaymentView: XibView {
    @IBOutlet private weak var paymentStack: UIStackView!
    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var loadingImage: UIImageView!
    
    public func setFeeViewModels(_ viewModels: [FeeViewModel]) {
        let sortedViewModels = getSortedViewModels(viewModels)
        self.paymentStack?.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        guard !sortedViewModels.isEmpty else {
            self.showLoading()
            return
        }
        self.hideLoading()
        var viewIndex: Int = 0
        sortedViewModels.forEach({
            let feeView = FeePaymentView()
            feeView.setViewModel($0, index: viewIndex)
            self.paymentStack.addArrangedSubview(feeView)
            viewIndex+=1
        })
    }
}

private extension FractionatedPaymentView {
    func hideLoading() {
        self.loadingView.isHidden = true
    }
    
    func showLoading() {
        self.loadingImage.setPointsLoader()
        loadingImage.clipsToBounds = false
        self.loadingView.isHidden = false
    }
    
    func getSortedViewModels(_ viewModels: [FeeViewModel]) -> [FeeViewModel] {
        let sortedViewModels = viewModels.sorted(by: {
            let month0 = Int($0.months) ?? 0
            let month1 = Int($1.months) ?? 0
            if month0 != 0, month1 != 0 {
                return month0 < month1
            }
            return false
        })
        return sortedViewModels
    }
}
