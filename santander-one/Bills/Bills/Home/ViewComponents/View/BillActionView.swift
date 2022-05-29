//
//  BillActionView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//

import Foundation
import CoreFoundationLib
import UI

protocol BillActionViewDelegate: AnyObject {
    func didSelectPayment()
    func didSelectDomicile()
}

final class BillActionView: XibView {
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var paymentImage: UIImageView!
    @IBOutlet weak var paymentDescriptionLabel: UILabel!
    @IBOutlet weak var domicileImageView: UIImageView!
    @IBOutlet weak var domicileLabel: UILabel!
    @IBOutlet weak var domicileSubtitleLabel: UILabel!
    @IBOutlet weak var domicileDescriptionLabel: UILabel!
    @IBOutlet var viewContainers: [UIView]!
    weak var delegate: BillActionViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.appearance()
        self.setAccessibilityIdentifiers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.appearance()
        self.setAccessibilityIdentifiers()
    }

    func setDelegate(_ delegate: BillActionViewDelegate?) {
        self.delegate = delegate
    }
    
    @IBAction func didSelectPayment(_ sender: Any) {
        self.delegate?.didSelectPayment()
    }
    
    @IBAction func didSelectDomicile(_ sender: Any) {
        self.delegate?.didSelectDomicile()
    }
}

private extension BillActionView {
    func appearance() {
        self.setLocalized()
        self.setViewColors()
        self.drawShadows()
        self.paymentImage.image = Assets.image(named: "rectangle")
        self.domicileImageView.image = Assets.image(named: "icnDomicile")
    }
    
    func setLocalized() {
        self.paymentLabel.configureText(
            withKey: "receiptsAndTaxes_lable_doingPayement",
            andConfiguration: LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .light, size: 22),
                lineHeightMultiple: 0.75,
                lineBreakMode: .byTruncatingTail
            )
        )
        self.paymentDescriptionLabel.configureText(
            withKey: "receiptsAndTaxes_text_doingPayement",
            andConfiguration: LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .regular, size: 14),
                lineHeightMultiple: 0.75,
                lineBreakMode: .byTruncatingTail
            )
        )
        self.domicileLabel.configureText(
            withKey: "receiptsAndTaxes_title_domicile",
            andConfiguration: LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .bold, size: 22),
                lineHeightMultiple: 0.75,
                lineBreakMode: .byTruncatingTail
            )
        )
        self.domicileSubtitleLabel.configureText(
            withKey: "receiptsAndTaxes_text_anyBank",
            andConfiguration: LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .regular, size: 10),
                lineHeightMultiple: 0.75,
                lineBreakMode: .byTruncatingTail
            )
        )
        self.domicileDescriptionLabel.configureText(
            withKey: "receiptsAndTaxes_text_domicile",
            andConfiguration: LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .regular, size: 14),
                lineHeightMultiple: 0.75,
                lineBreakMode: .byTruncatingTail
            )
        )
    }
    
    func setViewColors() {
        self.backgroundColor = .clear
        self.view?.backgroundColor = .skyGray
        self.paymentLabel.textColor = .lisboaGray
        self.paymentDescriptionLabel.textColor = .mediumSanGray
        self.domicileLabel.textColor = .lisboaGray
        self.domicileSubtitleLabel.textColor = .mediumSanGray
        self.domicileDescriptionLabel.textColor = .mediumSanGray
    }
    
    func drawShadows() {
        self.viewContainers.forEach {
            $0.drawBorder(cornerRadius: 4, color: .lightSkyBlue, width: 1)
            $0.drawShadow(offset: (x: 1, y: 2), color: .shadesWhite, radius: 2)
        }
    }
    
    private func setAccessibilityIdentifiers() {
        self.paymentLabel.accessibilityIdentifier = AccesibilityBills.BillActionView.payBillTitle
        self.paymentDescriptionLabel.accessibilityIdentifier = AccesibilityBills.BillActionView.payBillSubtitle
        self.domicileLabel.accessibilityIdentifier = AccesibilityBills.BillActionView.directDebitsTitle
        self.domicileSubtitleLabel.accessibilityIdentifier = AccesibilityBills.BillActionView.directDebitsAppendix
        self.domicileDescriptionLabel.accessibilityIdentifier = AccesibilityBills.BillActionView.directDebitsSubtitle
    }
}
