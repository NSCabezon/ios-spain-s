//
//  SendMoneyAccountSelectorHeaderView.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 9/9/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

final class SendMoneyAccountSelectorHeaderView: XibView {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var oneAlertView: OneAlertView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    func shouldShowAlert(_ show: Bool) {
        self.oneAlertView.isHidden = !show
    }
}

private extension SendMoneyAccountSelectorHeaderView {
    func setupViews() {
        self.imageView.image = Assets.image(named: "icnArrowSend")
        self.infoLabel.font = .typography(fontName: .oneH100Regular)
        self.infoLabel.textColor = .oneLisboaGray
        self.infoLabel.configureText(withKey: "originAccount_label_sentMoney")
        self.oneAlertView.setType(
            .textAndImage(imageKey: "icnInfo",
                          stringKey: "originAccount_label_infoWhithoutAccounts")
        )
        self.oneAlertView.isHidden = true
        self.setupAccessibilityInfo()
    }
    
    func setupAccessibilityInfo() {
        self.infoLabel.accessibilityIdentifier = AccessibilitySendMoneyAccountSelector.infoLabel
        self.imageView.accessibilityIdentifier = AccessibilitySendMoneyAccountSelector.sentIcon
        self.imageView.isAccessibilityElement = true
        self.imageView.accessibilityLabel = localized("voiceover_sendMoney")
        self.imageView.accessibilityTraits = .image
        self.infoLabel.accessibilityLabel = localized("voiceover_listAccounts")
        self.oneAlertView.accessibilityLabel = localized("originAccount_label_infoWhithoutAccounts")
        self.oneAlertView.isAccessibilityElement = true
        self.oneAlertView.accessibilityTraits = .staticText
    }
}
