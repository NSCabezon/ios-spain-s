//
//  PGClassicFooterTableViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 27/01/2020.
//

import UIKit
import CoreFoundationLib

protocol FooterTableViewCellProtocol {}

final class PGClassicFooterTableViewCell: UITableViewCell, GeneralPGCellProtocol, DiscretePGCellProtocol, SeparatorCellProtocol {
    
    @IBOutlet private weak var frameView: RoundedView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var amountLabel: UILabel?
    @IBOutlet private weak var titleHeightConstraint: NSLayoutConstraint!
    private var discreteMode: Bool = false
    private var isColapsed: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel?.text = ""
        amountLabel?.attributedText = nil
        discreteMode = false
        amountLabel?.removeBlur()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if discreteMode {
            guard !(amountLabel?.text?.isEmpty ?? true) else { amountLabel?.removeBlur(); return }
            amountLabel?.blur(5.0)
        }
    }
    
    func setDiscreteModeEnabled(_ enabled: Bool) {
        self.discreteMode = enabled
        self.setAccessibility(setViewAccessibility: self.setAccessibility)
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? GeneralFooterInfo else { return }
        self.titleLabel?.configureText(withLocalizedString: info.title)
        amountLabel?.attributedText = info.amount ?? NSAttributedString(string: localized("pgBasket_label_differentCurrency"))
        frameView?.roundBottomCornersJoined()
        self.setAmountLabelAccessibility()
    }
   
    func hideSeparator(_ hide: Bool) {
        if hide {
            titleHeightConstraint.constant = 0.0
            frameView?.roundBottomCorners()
        } else {
            titleHeightConstraint.constant = 12.0
            frameView?.roundBottomCornersJoined()
        }
        isColapsed = hide
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: isColapsed ? 35 : 47)
    }
    
    func setAccessibilityIdentifier(identifier: String? = nil) {
        if let identifier = identifier?.lowercased() {
            self.amountLabel?.accessibilityIdentifier = "pgClassic_\(identifier)_footer_amountLabel"
            self.titleLabel?.accessibilityIdentifier = "pgClassic_\(identifier)_footer_titleLabel"
            self.accessibilityIdentifier = "pgClassic_\(identifier)_footer"
        }
    }
}

private extension PGClassicFooterTableViewCell {
    func commonInit() {
        configureView()
        configureLabels()
        setAccessibility(setViewAccessibility: self.setAccessibility)
    }
    
    func configureView() {
        selectionStyle = .none
        clipsToBounds = false
        frameView?.clipsToBounds = false
        frameView?.backgroundColor = UIColor.bg
        frameView?.frameBackgroundColor = UIColor.white.cgColor
        frameView?.frameCornerRadious = 6.0
        frameView?.layer.borderWidth = 0.0
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        contentView.backgroundColor = UIColor.skyGray
        
        backgroundColor = UIColor.clear
    }
    
    func configureLabels() {
        titleLabel?.setSantanderTextFont(type: .regular, size: 16, color: .grafite)
        amountLabel?.font = UIFont.santander(family: .text, type: .bold, size: 22.0)
        amountLabel?.textColor = UIColor.lisboaGray
    }

    func setAccessibility() {
        guard let titleLabel = self.titleLabel?.text,
              let amountLabel = self.amountLabel?.text else { return }
        let title = self.discreteMode ? "" : titleLabel
        let amount = self.discreteMode ? "" : self.replaceLetteWithValue(amount: amountLabel)
        self.accessibilityLabel = self.discreteMode ? "" : "\(title) \n \(amount)"
    }
    
    func replaceLetteWithValue(amount: String) -> String {
        var amountNew = amount.replacingOccurrences(of: "B", with: localized("voiceover_billions"))
        amountNew = amountNew.replacingOccurrences(of: "M", with: localized("voiceover_millons"))
        return amountNew
    }
}

extension PGClassicFooterTableViewCell: FooterTableViewCellProtocol {}

extension PGClassicFooterTableViewCell {
    func  setAmountLabelAccessibility() {
        guard let label = self.amountLabel?.attributedText?.string else { return }
           let billons = localized("voiceover_billions").text
           let millons = localized("voiceover_millons").text
        self.amountLabel?.accessibilityLabel = label.replacingOccurrences(of: "B", with: billons)
        self.amountLabel?.accessibilityLabel = label.replacingOccurrences(of: "M", with: millons)
       }
}

extension PGClassicFooterTableViewCell: AccessibilityCapable { }
