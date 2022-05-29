//
//  MonthsTransfersEmptyView.swift
//  Menu
//
//  Created by David Gálvez Alonso on 04/06/2020.
//

import UI
import CoreFoundationLib

final class MonthsTransfersEmptyView: XibView {
    
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setTitleKey(_ key: LocalizedStylableText) {
        self.titleLabel.configureText(withLocalizedString: key,
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, size: 20.0),
                                                                                           lineHeightMultiple: 0.7))
    }
}

private extension MonthsTransfersEmptyView {
    
    func setAppearance() {
        self.titleLabel.configureText(withKey: "transfer_title_emptyView_recent",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, size: 20.0)))
        self.emptyImageView.image = Assets.image(named: "imgLeaves")
        self.titleLabel?.textColor = .lisboaGray
    }
}
