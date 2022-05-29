//
//  ProductHeaderTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/2/20.
//

import UIKit
import UI
import CoreFoundationLib

protocol ProductHeaderTableViewCellDelegate: AnyObject {
    func didSelectProductHeaderCell(_ cell: ProductHeaderTableViewCell)
}

class ProductHeaderTableViewCell: UITableViewCell {
    static let identifier = "ProductHeaderTableViewCell"
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var numberOfDebitsLabel: UILabel!
    @IBOutlet weak var sanIconImageView: UIImageView!
    @IBOutlet weak var viewContainer: HeaderContainerView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var viewContainerBottomConstraint: NSLayoutConstraint!
    weak var delegate: ProductHeaderTableViewCellDelegate?
    private var viewModel: ProductGroupViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
        self.setAccessibilityIdentifiers()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setAppearance()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: ProductGroupViewModel) {
        self.viewModel = viewModel
        self.nameLabel.text = viewModel.name
        self.accountNumberLabel.text = viewModel.accountNumber
        self.numberOfDebitsLabel.configureText(withLocalizedString: viewModel.debitsNumberLocalized)
        self.sanIconImageView.image = Assets.image(named: "icn_santander_cards")
        self.setAppearance()
    }
    
    @IBAction func didSelectExpandOrCollapse(_ sender: Any) {
        self.viewModel?.toggle()
        self.delegate?.didSelectProductHeaderCell(self)
    }
    
    private func setAppearance() {
        self.arrowImageView.image = Assets.image(named: "icnArrowDownSlim")
        if let viewModel = self.viewModel, viewModel.isExpanded {
            self.setExpandedAppearance()
        } else {
            self.setCollapsedAppearance()
        }
    }
}

private extension ProductHeaderTableViewCell {
    func setExpandedAppearance() {
        self.viewContainerBottomConstraint.constant = 0
        self.viewContainer.drawCornerExceptBottom()
        self.viewContainer.backgroundColor = .skyGray
        self.arrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    func setCollapsedAppearance() {
        self.viewContainerBottomConstraint.constant = 3
        self.viewContainer.drawAllCornersWithShadow()
        self.viewContainer.backgroundColor = .white
        self.arrowImageView.transform = .identity
    }
    
    private func setAccessibilityIdentifiers() {
        self.nameLabel.accessibilityIdentifier = AccesibilityBills.LastBillProductHeaderView.lastBillProductTitleTextView
        self.accountNumberLabel.accessibilityIdentifier = AccesibilityBills.LastBillProductHeaderView.lastBillProductShortIbanTextView
        self.numberOfDebitsLabel.accessibilityIdentifier = AccesibilityBills.LastBillProductHeaderView.billsAndTaxesPaymentCounterTextView
        self.sanIconImageView.accessibilityIdentifier = AccesibilityBills.LastBillProductHeaderView.lastBillProductBankImageView
        self.arrowImageView.accessibilityIdentifier = AccesibilityBills.LastBillProductHeaderView.productDeployImageView
    }
}
