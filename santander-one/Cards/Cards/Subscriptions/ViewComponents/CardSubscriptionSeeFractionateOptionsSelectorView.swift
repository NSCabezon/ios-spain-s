//
//  CardSubscriptionSeeFractionateOptionsSelectorView.swift
//  Cards
//
//  Created by Ignacio González Miró on 4/5/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol CardSubscriptionSeeFractionateOptionsSelectorViewDelegate: AnyObject {
    func didTapInSelector()
}

public final class CardSubscriptionSeeFractionateOptionsSelectorView: XibView {
    @IBOutlet private weak var seeFractionableOptionsView: SeeFractionableOptionsView!

    weak var delegate: CardSubscriptionSeeFractionateOptionsSelectorViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ isExpanded: Bool, feeViewModels: [FeeViewModel]) {
        seeFractionableOptionsView.delegate = self
        seeFractionableOptionsView.configView(isExpanded, feeViewModels: feeViewModels)
    }
}

private extension CardSubscriptionSeeFractionateOptionsSelectorView {
    func setupView() {
        backgroundColor = .clear
    }
}

extension CardSubscriptionSeeFractionateOptionsSelectorView: DidTapInSeeFractionableOptionsViewDelegate {
    public func didTapInSelector() {
        delegate?.didTapInSelector()
    }
}
