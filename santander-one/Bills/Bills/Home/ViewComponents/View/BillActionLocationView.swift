//
//  BillActionLocationView.swift
//  Bills
//
//  Created by Ignacio González Miró on 25/5/21.
//

import UIKit
import UI

protocol DidTapInBillActionLocationViewDelegate: AnyObject {
    func didTapInLocation()
}

public final class BillActionLocationView: XibView {
    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    weak var delegate: DidTapInBillActionLocationViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        baseView.drawBorder(cornerRadius: 4, color: .lightSkyBlue, width: 1)
    }
}

private extension BillActionLocationView {
    func setupView() {
        backgroundColor = .clear
        baseView.backgroundColor = .white
        configLocationPill()
        addTapGesture()
    }
    
    func configLocationPill() {
        baseView.drawShadow(offset: (x: 1, y: 2), color: .shadesWhite, radius: 2)
        imageView.image = Assets.image(named: "icnFinancingOfReceipts")
        setTitle()
        setDescription()
        setAccessibilityIds()
    }
    
    func setTitle() {
        let localizedConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16), alignment: .left, lineBreakMode: .byTruncatingTail)
        titleLabel.configureText(withKey: "receiptsAndTaxes_title_financeReceipts",
                                 andConfiguration: localizedConfig)
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .lisboaGray
    }
    
    func setDescription() {
        let localizedConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 12), alignment: .left, lineHeightMultiple: 0.85, lineBreakMode: .none)
        descriptionLabel.configureText(withKey: "receiptsAndTaxes_text_financeReceipts",
                                       andConfiguration: localizedConfig)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = "receiptsAndTaxesBtnFinanceReceipts"
        imageView.accessibilityIdentifier = "icnFinancingOfReceipts"
        titleLabel.accessibilityIdentifier = "receiptsAndTaxes_title_financeReceipts"
        descriptionLabel.accessibilityIdentifier = "receiptsAndTaxes_text_financeReceipts"
    }
    
    func addTapGesture() {
        if let gestures = gestureRecognizers, !gestures.isEmpty {
            gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInLocation))
        addGestureRecognizer(tap)
    }
    
    @objc func didTapInLocation() {
        delegate?.didTapInLocation()
    }
}
