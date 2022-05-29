//
//  InterventionFilterOptionTableViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 30/12/2019.
//

import UIKit
import UI
import CoreFoundationLib

protocol InterventionFilterOptionTableViewCellDelegate: AnyObject {
    func didSelectFilter(_ filter: PGInterventionFilter)
}

protocol InterventionFilterOptionTableViewCellProtocol: AnyObject {
    var delegate: InterventionFilterOptionTableViewCellDelegate? { get set }
}

class InterventionFilterOptionTableViewCell: UITableViewCell, GeneralPGCellProtocol, InterventionFilterOptionTableViewCellProtocol {
    
    @IBOutlet weak var frameView: RoundedView?
    @IBOutlet weak var allLabel: UILabel?
    @IBOutlet weak var ownerLabel: UILabel?
    @IBOutlet weak var authorizedLabel: UILabel?
    @IBOutlet weak var representativeLabel: UILabel?
    
    weak var delegate: InterventionFilterOptionTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configureLabels()
    }

    // MARK: - GeneralPGCellProtocol method
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? PGInterventionFilter else { return }
        unselectAll()
        select(info)
    }
    
    @objc private func allDidPressed() {
        select(.all)
        delegate?.didSelectFilter(.all)
    }
    @objc private func ownerDidPressed() {
        select(.owner)
        delegate?.didSelectFilter(.owner)
    }
    @objc private func authorizedDidPressed() {
        select(.authorised)
        delegate?.didSelectFilter(.authorised)
    }
    @objc private func representativeDidPressed() {
        select(.legalRepresentative)
        delegate?.didSelectFilter(.legalRepresentative)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 175.0)
    }
}

private extension InterventionFilterOptionTableViewCell {
    func select(_ filter: PGInterventionFilter) {
        unselectAll()
        switch filter {
        case .all:
            select(allLabel)
        case .owner:
            select(ownerLabel)
        case .authorised:
            select(authorizedLabel)
        case .legalRepresentative:
            select(representativeLabel)
        }
    }
    
    func commonInit() {
        configureView()
        configureLabels()
        addTapGestures()
        setAccessibilityIdentifiers()
    }
    
    func configureView() {
        selectionStyle = .none
        frameView?.clipsToBounds = true
        frameView?.backgroundColor = UIColor.clear
        frameView?.frameBackgroundColor = UIColor.white.cgColor
        frameView?.frameStrokeColor = UIColor.lightSkyBlue.cgColor
        frameView?.frameCornerRadious = 6.0
        frameView?.layer.borderWidth = 0.0
        frameView?.roundBottomCornersJoined()
        
        frameView?.layer.masksToBounds = false
        frameView?.layer.shadowRadius = 3
        frameView?.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        frameView?.layer.shadowOpacity = 0.5
        frameView?.layer.shadowColor = UIColor.lightSanGray.cgColor
    }
    
    func configureLabels() {
        let filters = PGInterventionFilter.allCases
        [allLabel, ownerLabel, authorizedLabel, representativeLabel].enumerated().forEach { configureLabel($0.element, filters[$0.offset].desc()) }
        self.setAccessibility()
    }
    
    func configureLabel(_ label: UILabel?, _ title: String) {
        label?.text = localized(title)
        label?.font = UIFont.santander(family: .text, size: 15.0)
        label?.textColor = UIColor.lisboaGray
        label?.isUserInteractionEnabled = true
    }
    
    func select(_ label: UILabel?) {
        label?.textColor = UIColor.darkTorquoise
        label?.font = UIFont.santander(type: .bold, size: 15.0)
    }
    
    func unselect(_ label: UILabel?) {
        label?.textColor = UIColor.lisboaGray
        label?.font = UIFont.santander(size: 15.0)
    }
    
    func unselectAll() {
        [allLabel, ownerLabel, authorizedLabel, representativeLabel].forEach { unselect($0) }
    }
    
    func addTapGestures() {
        allLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(allDidPressed)))
        ownerLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ownerDidPressed)))
        authorizedLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(authorizedDidPressed)))
        representativeLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(representativeDidPressed)))
    }
    
    func setAccessibility() {
        self.accessibilityElements = [ self.allLabel, self.ownerLabel, self.authorizedLabel, self.representativeLabel ]
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityGlobalPosition.pgFilterOptionsView
        allLabel?.accessibilityIdentifier = AccessibilityGlobalPosition.pgFilterOptionsAll
        ownerLabel?.accessibilityIdentifier = AccessibilityGlobalPosition.pgFilterOptionsOwner
        authorizedLabel?.accessibilityIdentifier = AccessibilityGlobalPosition.pgFilterOptionsAuth
        representativeLabel?.accessibilityIdentifier = AccessibilityGlobalPosition.pgFilterOptionsRepresentative
    }
}
