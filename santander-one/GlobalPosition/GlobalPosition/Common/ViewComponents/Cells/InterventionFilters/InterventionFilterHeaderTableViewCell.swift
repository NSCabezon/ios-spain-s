//
//  InterventionFilterHeaderTableViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 30/12/2019.
//

import UIKit
import UI
import CoreFoundationLib

class InterventionFilterHeaderTableViewCell: UITableViewCell, GeneralPGCellProtocol {
    
    @IBOutlet weak var iconImage: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var optionLabel: UILabel?
    @IBOutlet weak var expandImage: UIImageView?
    @IBOutlet weak var separationView: UIView?
    
    private var open: Bool = true {
        didSet {
            separationView?.isHidden = open
            updateArrow()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        optionLabel?.text = ""
        open = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        open = !open
        super.touchesEnded(touches, with: event)
    }
    
    // MARK: - GeneralPGCellProtocol method
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? PGInterventionFilterModel else { return }
        optionLabel?.text = localized(info.filter.desc())
        open = info.selected
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 54.0)
    }
}

private extension InterventionFilterHeaderTableViewCell {
    func commonInit() {
        self.configureView()
        self.configureLabels()
        self.configureImages()
        self.setAccessibility(setViewAccessibility: self.setAccessibility)
        self.setAccessibilityIdentifiers()
    }
    
    func configureView() {
        selectionStyle = .none
        backgroundColor = UIColor.skyGray
        separationView?.backgroundColor = UIColor.lightSkyBlue
    }
    
    func configureLabels() {
        titleLabel?.font = UIFont.santander(family: .text, size: 16.0)
        titleLabel?.textColor = UIColor.mediumSanGray
        titleLabel?.text = localized("pg_label_filter_pb")
        optionLabel?.font = UIFont.santander(family: .text, size: 16.0)
        optionLabel?.textColor = UIColor.darkTorquoise
    }
    
    func configureImages() {
        iconImage?.image = Assets.image(named: "icnUser")
        expandImage?.image = Assets.image(named: "icnExpandMore")
        iconImage?.isAccessibilityElement = true
        expandImage?.isAccessibilityElement = true
    }
    
    func updateArrow() {
        let rotation = open ? self.transform.rotated(by: CGFloat.pi) : CGAffineTransform.identity
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.expandImage?.transform = rotation
        }
        expandImage?.accessibilityIdentifier = open ? AccessibilityGlobalPosition.pgFilterOptionsExpandOpen : AccessibilityGlobalPosition.pgFilterOptionsExpandClosed
    }
    
    func setAccessibility() {
        self.accessibilityElements = [ self.titleLabel, self.optionLabel]
        iconImage?.isAccessibilityElement = false
        expandImage?.isAccessibilityElement = false
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityGlobalPosition.pgFilterView
        iconImage?.accessibilityIdentifier = AccessibilityGlobalPosition.pgFilterUserIcn
        iconImage?.image?.accessibilityIdentifier = AccessibilityGlobalPosition.pgFilterUserIcn
        titleLabel?.accessibilityIdentifier = AccessibilityGlobalPosition.pgFilterTitleLabel
        optionLabel?.accessibilityIdentifier = AccessibilityGlobalPosition.pgFilterOptionsLabel
        expandImage?.accessibilityIdentifier = AccessibilityGlobalPosition.pgFilterOptionsExpandClosed
    }
}

extension InterventionFilterHeaderTableViewCell: AccessibilityCapable { }
