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

final class InternalTransferAccountSelectorShowMoreCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var containerView: UIView!
    private var numberPlaceHolder: Int?
    private var didSetCellInfo: Bool = false
    
    private var open: Bool = false {
        didSet {
            updateArrow()
            guard open else {
                configureCloseCell()
                return
            }
            configureOpenCell()
        }
    }
    
    static var bundle: Bundle? {
        return .module
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
        setAccessibilityIdentifiers()
        containerView.isAccessibilityElement = true
        titleLabel.isAccessibilityElement = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        open = !open
    }
    
    func setCellInfo(_ item: LabelArrowViewItem, isExpanded: Bool, backgroundColor: UIColor? = nil) {
        numberPlaceHolder = item.numberPlaceHolder
        checkFirstAppear(isExpanded: isExpanded)
    }
}

private extension InternalTransferAccountSelectorShowMoreCell {
    func updateArrow() {
        let rotation = open ? transform.rotated(by: CGFloat.pi) : CGAffineTransform.identity
        if didSetCellInfo {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.arrowImageView?.transform = rotation
            }
        } else {
            arrowImageView.transform = rotation
        }
    }
    
    func configureCell() {
        titleLabel.font = .typography(fontName: .oneB300Bold)
        titleLabel.textColor = .oneDarkTurquoise
        arrowImageView?.image = Assets.image(named: "icnArrowDownGreen")
    }
    
    func configureOpenCell() {
        guard let numberPlaceHolder = self.numberPlaceHolder else { return }
        titleLabel.configureText(withLocalizedString: localized("originAccount_label_CollapseHiddenAccounts", [StringPlaceholder(.number, String(numberPlaceHolder ))]))
        containerView.accessibilityLabel = localized("voiceover_collapseHiddenAccounts", [StringPlaceholder(.number, String(numberPlaceHolder ))]).text
        containerView.accessibilityHint = localized("voiceover_close")
    }
    
    func configureCloseCell() {
        guard let numberPlaceHolder = self.numberPlaceHolder else { return }
        titleLabel.configureText(withLocalizedString: localized("originAccount_label_seeHiddenAccounts", [StringPlaceholder(.number, String(numberPlaceHolder ))]))
        containerView.accessibilityLabel = localized("voiceover_seeHiddenAccounts", [StringPlaceholder(.number, String(numberPlaceHolder ))]).text
        containerView.accessibilityHint = localized("voiceover_open")
    }
    
    func setAccessibilityIdentifiers() {
        accessibilityIdentifier = AccessibilitySendMoneyAccountSelector.oneLinkView
        containerView.accessibilityIdentifier = AccessibilitySendMoneyAccountSelector.oneLinkBtn
    }
    
    func checkFirstAppear(isExpanded: Bool) {
        if didSetCellInfo == false {
            open = isExpanded
            didSetCellInfo = true
        }
    }
}
