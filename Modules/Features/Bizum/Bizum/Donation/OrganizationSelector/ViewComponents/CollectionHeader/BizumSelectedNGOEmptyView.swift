//
//  BizumSelectedNGOEmptyView.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 17/02/2021.
//

import Foundation
import UI
import CoreFoundationLib

final class BizumSelectedNGOEmptyView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension BizumSelectedNGOEmptyView {
    func setupView() {
        self.imageView.image = Assets.image(named: "imgLeaves")
        let textConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 20))
        self.titleLabel.configureText(withLocalizedString: localized("bizum_title_emptyView"),
                            andConfiguration: textConfiguration)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.accessibilityIdentifier = AccessibilityBizumDonation.emptyViewLabel
    }
}
