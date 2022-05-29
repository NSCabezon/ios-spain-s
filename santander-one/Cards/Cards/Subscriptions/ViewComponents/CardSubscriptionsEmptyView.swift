//
//  CardSubscriptionsEmptyView.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 01/03/2021.
//

import CoreFoundationLib
import UI

final public class CardSubscriptionsEmptyView: UIDesignableView {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    public override func getBundleName() -> String {
        return "Cards"
    }
    
    public override func commonInit() {
        super.commonInit()
        setupView()
    }
}

public extension CardSubscriptionsEmptyView {
    func updateTitle(_ title: LocalizedStylableText) {
        self.titleLabel.configureText(withLocalizedString: title)
    }
    
    func updateSubtitle(_ title: LocalizedStylableText) {
        self.subtitleLabel.configureText(withLocalizedString: title,
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16),
                                                                                              lineHeightMultiple: 0.75))
    }
}

private extension CardSubscriptionsEmptyView {
    func setupView() {
        self.titleLabel.setSantanderTextFont(type: .bold, size: 20.0, color: .darkTorquoise)
        self.subtitleLabel.textColor = .brownishGray
        self.imageView.image = Assets.image(named: "imgEmtySubscriptions")
        self.drawBorder(cornerRadius: 6, color: .lightSanGray, width: 0.4)
        self.backgroundColor = .clear
    }
}
