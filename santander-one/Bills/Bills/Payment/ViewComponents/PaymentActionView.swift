//
//  PaymentActionView.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 03/04/2020.
//

import UIKit
import UI

protocol PaymentActionViewDelegate: AnyObject {
    func didSelectAction(type: BillsAndTaxesTypeOperativePayment)
}

class PaymentActionView: XibView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    private var viewModel: PaymentViewModel?
    weak var delegate: PaymentActionViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: PaymentViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
        self.iconImageView.image = Assets.image(named: viewModel.imageName)
        switch viewModel.type {
        case .bills:
            self.accessibilityIdentifier = "btnReceipts"
            self.titleLabel.accessibilityIdentifier = "receiptsAndTaxes_button_receipts"
            self.descriptionLabel.accessibilityIdentifier = "receiptsAndTaxes_button_receiptsText"
        case .taxes:
            self.accessibilityIdentifier = "btnTaxes"
            self.titleLabel.accessibilityIdentifier = "receiptsAndTaxes_button_taxes"
            self.descriptionLabel.accessibilityIdentifier = "receiptsAndTaxes_text_taxes"
        case .billPayment:
            self.accessibilityIdentifier = "icnOtherPayments"
            self.titleLabel.accessibilityIdentifier = "receiptsAndTaxes_button_otherPayment"
            self.descriptionLabel.accessibilityIdentifier = "receiptsAndTaxes_text_otherPayment"
        }
    }
    
    @IBAction func paymentActionPresset(_ sender: Any) {
        
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectAction(type: viewModel.type)
    }
}

private extension PaymentActionView {
    func setAppearance() {
        self.configLabels()
        self.configContainerView()
        self.configImageViews()
    }
    
    func configLabels() {
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 16.0)
        self.titleLabel.textColor = .lisboaGray
        self.descriptionLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        self.descriptionLabel.textColor = .grafite
    }
    
    func configContainerView() {
        self.containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.containerView.layer.shadowOpacity = 0.59
        self.containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.containerView.layer.shadowRadius = 0.0
        self.containerView?.drawBorder(cornerRadius: 5, color: UIColor.lightSkyBlue, width: 1)
    }
    
    func configImageViews() {
        self.arrowImageView.image = Assets.image(named: "icnArrowRightGray")
        self.iconImageView.clipsToBounds = false
    }
}
