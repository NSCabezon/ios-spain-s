//
//  SeeFractionableOptionsHeaderView.swift
//  UI
//
//  Created by Ignacio González Miró on 28/4/21.
//

import UIKit
import CoreFoundationLib

public protocol DidTapInSelectorDelegate: AnyObject {
    func didTapInSelector()
    
}

public final class SeeFractionableOptionsHeaderView: XibView {
    @IBOutlet private weak var financeableImageView: UIImageView!
    @IBOutlet private weak var seeOptionLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    weak var delegate: DidTapInSelectorDelegate?
    private var isExpanded: Bool?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ isExpanded: Bool) {
        self.isExpanded = isExpanded
        arrowImageView.image = !isExpanded
            ? Assets.image(named: "icnArrowDownSlim")
            : Assets.image(named: "icnArrowUpSlim")
    }
}

private extension SeeFractionableOptionsHeaderView {
    func setupView() {
        backgroundColor = .clear
        financeableImageView.image = Assets.image(named: "icnFinancingAmortization")
        setTitleLabel()
        addTapGesture()
        setAccessibilityIds()
    }
    
    func setTitleLabel() {
        let configuration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14), alignment: .left, lineBreakMode: .byTruncatingTail)
        seeOptionLabel.configureText(withKey: "financing_button_seeOptions", andConfiguration: configuration)
        seeOptionLabel.textColor = .darkTorquoise
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilitySeeFractionableOptions.headerBaseView
        financeableImageView.accessibilityIdentifier = AccessibilitySeeFractionableOptions.headerFinanceableImage
        seeOptionLabel.accessibilityIdentifier = AccessibilitySeeFractionableOptions.headerSeeOptionLabel
        arrowImageView.accessibilityIdentifier = AccessibilitySeeFractionableOptions.headerArrowImage
    }
    
    // MARK: Tap action
    func addTapGesture() {
        if let recognizers = gestureRecognizers, !recognizers.isEmpty {
            self.gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInSelector))
        addGestureRecognizer(tap)
    }
    
    @objc func didTapInSelector() {
        delegate?.didTapInSelector()
    }
}
