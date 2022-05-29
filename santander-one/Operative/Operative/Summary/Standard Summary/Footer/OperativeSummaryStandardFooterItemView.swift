//
//  SummaryFooterItem.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 1/13/20.
//

import UIKit
import UI

public class OperativeSummaryStandardFooterItemView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var actionButton: UIButton!
    private var action: (() -> Void)?
    
    public convenience init(_ viewModel: OperativeSummaryStandardFooterItemViewModel) {
        self.init(frame: .zero)
        self.titleLabel.setSantanderTextFont(size: 14, color: .white)
        self.titleLabel.text = viewModel.title
        self.action = viewModel.action
        self.iconImageView.image = viewModel.image?.withRenderingMode(.alwaysTemplate)
        self.iconImageView.tintColor = .white
        self.setAcessibilityIds(viewModel.accessibilityIdentifier)
        setAccessibility()
    }
    
    @IBAction private func didSelectView() {
        self.action?()
    }
}

private extension OperativeSummaryStandardFooterItemView {
    func setAcessibilityIds(_ identifier: String?) {
        guard let identifier = identifier else { return }
        self.titleLabel.accessibilityIdentifier = identifier + "_label"
        self.iconImageView.accessibilityIdentifier = identifier + "_icon"
        self.actionButton.accessibilityIdentifier = identifier
    }
    
    func setAccessibility() {
        titleLabel.accessibilityElementsHidden = true
        actionButton.accessibilityLabel = titleLabel.text
    }
}
