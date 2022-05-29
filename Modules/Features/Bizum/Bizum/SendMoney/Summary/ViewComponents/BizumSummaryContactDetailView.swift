//
//  BizumSummaryContactDetailView.swift
//  Bizum
//
//  Created by Jose C. Yebes on 14/10/2020.
//

import UI

final class BizumSummaryContactDetailView: XibView {
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var statusLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var bulletView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    convenience init(_ viewModel: BizumSummaryRecipientItemViewModel) {
        self.init(frame: .zero)
        self.setupView()
        self.setupViewModel(viewModel)
    }
}

private extension BizumSummaryContactDetailView {
    func setupView() {
        let cornerRadius = bulletView.layer.frame.width / 2
        bulletView.layer.cornerRadius = cornerRadius
        bulletView.backgroundColor = .bostonRedLight
        self.setAccessibilityIdentifiers()
    }
    
    func setupViewModel(_ viewModel: BizumSummaryRecipientItemViewModel) {
        nameLabel.setSantanderTextFont(type: .bold, size: 14.0, color: .lisboaGray)
        nameLabel.text = viewModel.name
        statusLabel.setSantanderTextFont(type: .regular, size: 12.0, color: .grafite)
        statusLabel.text = viewModel.status.lowercased().capitalizingFirstLetter()
        amountLabel.textColor = .lisboaGray
        amountLabel.attributedText = viewModel.amountAttributeString
    }
    
    func setAccessibilityIdentifiers() {
        self.nameLabel.accessibilityIdentifier = AccessibilityBizumSummary.destinationName
        self.amountLabel.accessibilityIdentifier = AccessibilityBizumSummary.destinationAmount
        self.statusLabel.accessibilityIdentifier = AccessibilityBizumSummary.destinationStatus
    }
}
