//
//  TotalAmountView.swift
//  Loans
//
//  Created by Andres Aguirre Juarez on 6/10/21.
//

import UI
import CoreFoundationLib

final class TotalAmountView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configure(_ amount: NSAttributedString?) {
        amountLabel.attributedText = amount
    }
}

private extension TotalAmountView {
    func setupView() {
        backgroundColor = .clear
        titleLabel.configureText(withKey: "confirmation_label_totalOperation",
                                 andConfiguration: LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text,
                                                                                                             type: .regular,
                                                                                                             size: 14),
                                                                                      alignment: .center,
                                                                                      lineHeightMultiple: 0.75,
                                                                                      lineBreakMode: .byTruncatingTail))
        titleLabel.textColor = .grafite
        amountLabel.textColor = .lisboaGray
        containerView.backgroundColor = .veryLightGray
    }
}
