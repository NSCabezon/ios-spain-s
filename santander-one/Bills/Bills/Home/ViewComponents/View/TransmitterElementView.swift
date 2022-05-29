//
//  TransmitterElementView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/7/20.
//

import Foundation
import UI
import CoreFoundationLib

final class TransmitterElementView: XibView {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var billDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    private weak var delegate: TransmitterContentSheetBuilderDelegate?
    private var viewModel: LastBillViewModel?
    
    func setDelegate(_ delegate: TransmitterContentSheetBuilderDelegate?) {
        self.delegate = delegate
    }
    
    func setViewModel(_ viewModel: LastBillViewModel) {
        self.viewModel = viewModel
        self.billDateLabel.configureText(withLocalizedString: viewModel.dateLocalized)
        self.amountLabel.attributedText = viewModel.amountAttributedText
        self.viewContainer.drawRoundedAndShadowedNew(radius: 6, borderColor: .lightSkyBlue)
        self.setAccessibilityIdentifiers()
    }
    
    @IBAction func didSelectBill(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectLastBillViewModelFromSheetView(viewModel)
    }
}

private extension TransmitterElementView {
    func setAccessibilityIdentifiers() {
        self.billDateLabel.accessibilityIdentifier = AccesibilityBills.TransmitterElementView.lastBillCardViewIssuingItemDateTextView
        self.amountLabel.accessibilityIdentifier = AccesibilityBills.TransmitterElementView.lastBillCardViewIssuingItemAmountText
    }
}
