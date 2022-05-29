//
//  BizumSummaryRecipientsContainerView.swift
//  Bizum
//
//  Created by Jose C. Yebes on 14/10/2020.
//

import UI

final class BizumSummaryRecipientsContainerView: XibView {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var recipientsStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(_ title: String) {
        self.init(frame: .zero)
        titleLabel.setSantanderTextFont(type: .regular, size: 13.0, color: .grafite)
        titleLabel.text = title
        self.setAccesibilityIdentifiers()
    }
    
    func addReceiver(_ view: BizumSummaryContactDetailView) {
        self.recipientsStackView.addArrangedSubview(view)
    }
}

private extension BizumSummaryRecipientsContainerView {
    func setAccesibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityBizumSummary.summaryRecipientLabel
    }
}
