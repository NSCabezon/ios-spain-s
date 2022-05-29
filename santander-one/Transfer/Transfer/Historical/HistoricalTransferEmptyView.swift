//
//  HistoricalEmittedTransferEmptyView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 08/04/2020.
//

import Foundation
import UIKit
import CoreFoundationLib
import UI

final class HistoricalTransferEmptyView: XibView {
    
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setTitleKey(_ key: String) {
        self.titleLabel.configureText(withKey: key)
    }
    
    func setTitle(_ text: LocalizedStylableText) {
        self.titleLabel.configureText(withLocalizedString: text)
    }
    
    func setSubtitleKey(_ key: String?) {
        guard let key = key, !key.isEmpty else {
            self.subtitleLabel.isHidden = true
            return
        }
        self.subtitleLabel.configureText(withKey: key)
        self.subtitleLabel.isHidden = false
    }
}

private extension HistoricalTransferEmptyView {
    
    func setAppearance() {
        self.titleLabel.configureText(withKey: "transfer_title_emptyView_recent")
        self.emptyImageView.image = Assets.image(named: "imgLeaves")
        self.subtitleLabel.text = localized("transfer_text_emptyView_recent")
        self.titleLabel?.textColor = .lisboaGray
        self.titleLabel?.font = .santander(family: .headline, size: 20.0)
        self.subtitleLabel?.textColor = .lisboaGray
        self.subtitleLabel?.font = .santander(family: .headline, size: 14.0)
    }
}
