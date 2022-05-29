//
//  SeeFractionableOptionsView.swift
//  UI
//
//  Created by Ignacio González Miró on 28/4/21.
//

import UIKit
import CoreFoundationLib

public protocol DidTapInSeeFractionableOptionsViewDelegate: AnyObject {
    func didTapInSelector()
}

public final class SeeFractionableOptionsView: XibView {
    
    @IBOutlet private weak var stackView: UIStackView!

    public weak var delegate: DidTapInSeeFractionableOptionsViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawBorder(cornerRadius: 4, color: .mediumSkyGray, width: 1)
    }
    
    public func configView(_ isExpanded: Bool, feeViewModels: [FeeViewModel]) {
        removeArrangedSubviewsIfNeeded()
        addHeaderView(isExpanded)
        if isExpanded {
            addFractionableOptionsView(feeViewModels)
        }
    }
}

private extension SeeFractionableOptionsView {
    func setupView() {
        backgroundColor = .clear
    }
    
    func addHeaderView(_ isExpanded: Bool) {
        let view = SeeFractionableOptionsHeaderView()
        view.delegate = self
        view.configView(isExpanded)
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        stackView.addArrangedSubview(view)
    }
    
    func addFractionableOptionsView(_ viewModels: [FeeViewModel]) {
        let view = FractionatedPaymentView()
        view.backgroundColor = .white
        view.setFeeViewModels(viewModels)
        stackView.addArrangedSubview(view)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        self.stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

extension SeeFractionableOptionsView: DidTapInSelectorDelegate {
    public func didTapInSelector() {
        delegate?.didTapInSelector()
    }
}
