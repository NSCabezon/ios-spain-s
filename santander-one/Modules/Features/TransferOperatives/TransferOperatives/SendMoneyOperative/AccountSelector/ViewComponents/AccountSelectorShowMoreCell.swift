//
//  AccountSelectorShowMoreCell.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 9/9/21.
//

import UIKit
import UI
import CoreFoundationLib
import UIOneComponents

final class AccountSelectorShowMoreCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var containerView: UIView!
    private var numberPlaceHolder: Int?
    private var didSetCellInfo: Bool = false
    
    private var open: Bool = false {
        didSet {
            self.updateArrow()
            guard let numberPlaceHolder = self.numberPlaceHolder else { return }
            if open {
                self.titleLabel.configureText(withLocalizedString: localized("originAccount_label_CollapseHiddenAccounts", [StringPlaceholder(.number, String(numberPlaceHolder ))]))
                self.containerView.accessibilityLabel = localized("voiceover_collapseHiddenAccounts", [StringPlaceholder(.number, String(numberPlaceHolder ))]).text
                self.containerView.accessibilityHint = localized("voiceover_close")
            } else {
                self.titleLabel.configureText(withLocalizedString: localized("originAccount_label_seeHiddenAccounts", [StringPlaceholder(.number, String(numberPlaceHolder ))]))
                self.containerView.accessibilityLabel = localized("voiceover_seeHiddenAccounts", [StringPlaceholder(.number, String(numberPlaceHolder ))]).text
                self.containerView.accessibilityHint = localized("voiceover_open")
            }
        }
    }
    
    static var bundle: Bundle? {
        return .module
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
        self.setAccessibilityIdentifiers()
        self.containerView.isAccessibilityElement = true
        self.titleLabel.isAccessibilityElement = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.open = !self.open
    }
    
    func setCellInfo(_ item: LabelArrowViewItem, isExpanded: Bool, backgroundColor: UIColor? = nil) {
        self.numberPlaceHolder = item.numberPlaceHolder
        self.checkFirstAppear(isExpanded: isExpanded)
    }
}

private extension AccountSelectorShowMoreCell {
    func updateArrow() {
        let rotation = self.open ? self.transform.rotated(by: CGFloat.pi) : CGAffineTransform.identity
        if self.didSetCellInfo {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.arrowImageView?.transform = rotation
            }
        } else {
            self.arrowImageView.transform = rotation
        }
    }
    
    func configureCell() {
        self.titleLabel.font = .typography(fontName: .oneB300Bold)
        self.titleLabel.textColor = .oneDarkTurquoise
        self.arrowImageView?.image = Assets.image(named: "icnArrowDownGreen")
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilitySendMoneyAccountSelector.oneLinkView
        self.containerView.accessibilityIdentifier = AccessibilitySendMoneyAccountSelector.oneLinkBtn
    }
    
    func checkFirstAppear(isExpanded: Bool) {
        if self.didSetCellInfo == false {
            self.open = isExpanded
            self.didSetCellInfo = true
        }
    }
}
