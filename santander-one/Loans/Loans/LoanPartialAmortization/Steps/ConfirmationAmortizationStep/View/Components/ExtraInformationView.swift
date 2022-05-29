//
//  ExtraInformationView.swift
//  Loans
//
//  Created by Andres Aguirre Juarez on 6/10/21.
//

import UI
import CoreFoundationLib

final class ExtraInformationView: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var firstLabel: UILabel!
    @IBOutlet private weak var secondLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configure(_ phone: String?) {
        if let phone = phone {
            let localized = localized("confirmation_textTelf_commissionsAmortization", [StringPlaceholder(.phone, phone)])
            secondLabel.configureText(withLocalizedString: localized,
                                     andConfiguration: LocalizedStylableTextConfiguration(
                                        font: UIFont.santander(family: .text,
                                                               type: .regular,
                                                               size: 12),
                                        alignment: .center,
                                        lineHeightMultiple: 0.75,
                                        lineBreakMode: .byTruncatingTail))

        } else {
            secondLabel.isHidden = true
        }
    }
}

private extension ExtraInformationView {
    func setupView() {
        backgroundColor = .veryLightGray
        firstLabel.configureText(withKey: "confirmation_text_commissionsAmortization",
                                 andConfiguration: LocalizedStylableTextConfiguration(
                                    font: UIFont.santander(family: .text,
                                                           type: .regular,
                                                           size: 12),
                                    alignment: .center,
                                    lineHeightMultiple: 0.75,
                                    lineBreakMode: .byTruncatingTail))
        firstLabel.numberOfLines = 0
        secondLabel.numberOfLines = 0
        firstLabel.textColor = .brownGray
        secondLabel.textColor = .brownGray
        containerView.backgroundColor = .skyGray
    }
}
