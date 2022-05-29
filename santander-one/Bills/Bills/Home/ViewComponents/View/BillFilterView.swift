//
//  BillFilterView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/24/20.
//

import Foundation
import CoreFoundationLib
import UI

protocol BillFilterViewDelegate: AnyObject {
    func didSelectFilter()
}

final class BillFilterView: XibView {
    @IBOutlet weak var lastBillLabel: UILabel!
    @IBOutlet weak var lastTwoMonthLabel: UILabel!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var bottomLine: UIView!
    private weak var delegate: BillFilterViewDelegate?
    
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
    
    func setDelegate(_ delegate: BillFilterViewDelegate) {
        self.delegate = delegate
    }
    
    func setMonths(months: Int) {
        let localizedMonths = localized("receiptsAndTaxes_text_lastReceipts",
                                        [StringPlaceholder(.number, "\(months)")])
        self.lastTwoMonthLabel.configureText(withLocalizedString: localizedMonths)
    }
    
    func setMonthsHidden() {
        self.lastTwoMonthLabel.isHidden = true
    }
    
    func showMonths() {
        self.lastTwoMonthLabel.isHidden = false
    }
    
    func hideFilterButton() {
        self.filterImageView.isHidden = true
        self.filterLabel.isHidden = true
        self.filterButton.isHidden = true
    }
    
    func showFilterButton() {
        self.filterImageView.isHidden = false
        self.filterLabel.isHidden = false
        self.filterButton.isHidden = false
    }
    
    private func appearance() {
        self.lastBillLabel.configureText(withLocalizedString: localized("receiptsAndTaxes_label_lastReceipts"))
        self.lastTwoMonthLabel.configureText(withLocalizedString: localized("receiptsAndTaxes_text_lastReceipts", [StringPlaceholder(.number, "2")]))
        self.filterLabel.configureText(withLocalizedString: localized("generic_button_filters"))
        self.filterImageView.image = Assets.image(named: "icnFilter")
        self.lastBillLabel.textColor = .lisboaGray
        self.lastTwoMonthLabel.textColor = .lisboaGray
        self.filterLabel.textColor = .darkTorquoise
        self.bottomLine.backgroundColor = .mediumSkyGray
        self.hideFilterButton()
    }
    
    @IBAction func didSelectFilter(_ sender: Any) {
        self.delegate?.didSelectFilter()
    }
}

private extension BillFilterView {
    private func setAccessibilityIdentifiers() {
        self.lastBillLabel.accessibilityIdentifier = AccesibilityBills.LastBillFilterView.lastBillsTitle
        self.lastTwoMonthLabel.accessibilityIdentifier = AccesibilityBills.LastBillFilterView.lastBillsSubtitle
    }
}
