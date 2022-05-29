//
//  OneTransferOptionsView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 15/12/21.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib

final class OneTransferOptionsView: XibView {
    @IBOutlet private weak var oneGradientView: OneGradientView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var oneHomeOptionsListView: OneHomeOptionsListView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setActions(_ viewModels: [SendMoneyHomeOption]) {
        oneHomeOptionsListView.setViewModels(viewModels)
    }
}

private extension OneTransferOptionsView {
    func setupView() {
        setLabel()
        oneGradientView.setupType(.oneGrayGradient())
        setAccessibilityIdentifiers()
    }
    
    func setLabel() {
        titleLabel.font = .typography(fontName: .oneH200Bold)
        titleLabel.textColor = .oneLisboaGray
        titleLabel.configureText(withKey: "transfer_title_options")
    }
    
    func setAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AccessibilityTransferHome.oneHomeListOptionsTitleView
        oneHomeOptionsListView.accessibilityIdentifier = AccessibilityTransferHome.oneHomeListOptionsView
    }
}
