//
//  PGGeneralHeaderView.swift
//  toTest
//
//  Created by alvola on 28/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import UI
import CoreDomain
import CoreFoundationLib

protocol PGGeneralHeaderViewDelegate: AnyObject {
    func didSelect(_ type: ProductTypeEntity)
}

protocol PGGeneralHeaderViewProtocol {
    func setDelegate(_ delegate: PGGeneralHeaderViewDelegate?)
    func roundBottom(_ rounded: Bool)
}

final class PGGeneralHeaderView: UITableViewHeaderFooterView, GeneralPGCellProtocol, PGGeneralHeaderViewProtocol {
    
    @IBOutlet weak var frameView: RoundedView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var movementLabel: UILabel?
    @IBOutlet weak var notificationLabel: UILabel?
    @IBOutlet weak var expandIcon: UIImageView?
    @IBOutlet weak var verticalLine: UIView!
    weak var delegate: PGGeneralHeaderViewDelegate?
    private var currentProductType: ProductTypeEntity?
    private var isCollapsable: Bool = true
    
    private var open: Bool = true {
        didSet {
            self.updateArrow()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel?.text = ""
        self.notificationLabel?.text = ""
        self.notificationLabel?.isHidden = true
        self.currentProductType = nil
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? PGClassicGeneralHeaderInfo else { return }
        self.titleLabel?.text = info.title
        self.open = info.open
        self.currentProductType = info.productType
        self.isCollapsable = info.isCollapsable
        self.expandIcon?.isHidden = !info.isCollapsable
        self.setAccessibilityIdentifiers(info: info)
        guard info.canHaveNotifications, let movCount = info.notification else {
            self.notificationLabel?.isHidden = true
            self.movementLabel?.isHidden = true
            self.verticalLine.isHidden = true
            return
        }
        self.notificationLabel?.text = String(movCount)
        let localizedText = (movCount > 1) ?
            PGCommonTexts.localizableTextForElement(.classicGeneralProductCell(.plural)) :
            PGCommonTexts.localizableTextForElement(.classicGeneralProductCell(.singular))
        self.movementLabel?.configureText(withLocalizedString: localizedText)
        self.verticalLine.isHidden = self.open
        self.notificationLabel?.isHidden = self.open
        self.movementLabel?.isHidden = self.open
        self.setAccessibility(setViewAccessibility: self.updateAccessibility)
    }
    
    func setDelegate(_ delegate: PGGeneralHeaderViewDelegate?) { self.delegate = delegate }
    func roundBottom(_ rounded: Bool) {
        rounded ?
            self.frameView?.roundAllCorners() :
            self.open ? self.frameView?.roundTopCornersJoined() : self.frameView?.roundTopCorners()
    }
    
    @objc func didTapHeader(_ sender: Any) {
        guard
            self.isCollapsable,
            let currentProductType = self.currentProductType
            else { return }
        self.delegate?.didSelect(currentProductType)
    }
}

private extension PGGeneralHeaderView {
    
    func commonInit() {
        self.configureView()
        self.configureLabels()
        self.configureImages()
        self.setAccessibility(setViewAccessibility: self.setAccessibility)
    }
    
    func configureView() {
        self.layer.borderColor = UIColor.clear.cgColor
        self.frameView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader(_:))))
        self.frameView?.backgroundColor = UIColor.clear
        self.frameView?.frameBackgroundColor = UIColor.white.cgColor
        self.frameView?.frameCornerRadious = 6.0
        self.frameView?.layer.borderWidth = 0.0
        self.frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.open ? self.frameView?.roundTopCornersJoined() : self.frameView?.roundTopCorners()
        self.contentView.backgroundColor = UIColor.skyGray
        self.verticalLine.backgroundColor = .brownGray
    }
    
    func configureLabels() {
        self.titleLabel?.font = UIFont.santander(type: .bold, size: 16.0)
        self.titleLabel?.textColor = UIColor.lisboaGray
        self.movementLabel?.textColor = .brownGray
        self.movementLabel?.font = .santander(size: 14.0)
        self.notificationLabel?.font = .santander(type: .bold, size: 14.0)
        self.notificationLabel?.textColor = .santanderRed
    }
    
    func configureImages() {
        self.expandIcon?.image = Assets.image(named: "icnArrowDown")
    }
    
    func updateArrow() {
        let rotation = open ? self.transform.rotated(by: CGFloat.pi) : CGAffineTransform.identity
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.expandIcon?.transform = rotation
        }
        expandIcon?.accessibilityIdentifier = open  ? "\(self.accessibilityIdentifier)_expandIconOpen" : "\(self.accessibilityIdentifier)_expandIconClosed"
        self.setAccessibility(setViewAccessibility: self.updateAccessibility)
    }
    
    func setAccessibility() {
        self.titleLabel?.accessibilityTraits = .button
        self.movementLabel?.isAccessibilityElement = false
        self.notificationLabel?.isAccessibilityElement = false
    }
    
    func updateAccessibility() {
        guard let title = self.titleLabel?.text else {return}
        if self.open {
            self.accessibilityLabel = "\(title) \n \(localized("voiceover_closeBreakdown"))"
            return
        } else {
            guard let numMovements = self.notificationLabel?.attributedText?.string,
                  let movementsLabel = self.movementLabel?.text else {
                self.accessibilityLabel = "\(title) \n \(localized("voiceover_seeBreakdown"))"
                return
            }
            self.accessibilityLabel = "\(title) \n \(numMovements) \(movementsLabel) \n \(localized("voiceover_seeBreakdown"))"
            return
        }
    }
    
    func setAccessibilityIdentifiers(info: PGClassicGeneralHeaderInfo) {
        self.accessibilityIdentifier = "pgClassic_\(info.productType.rawValue)_header"
        self.titleLabel?.accessibilityIdentifier = "pgClassic_\(info.productType.rawValue)_header_titleLabel"
        self.expandIcon?.isAccessibilityElement = true
        self.setAccessibility { self.expandIcon?.isAccessibilityElement = false }
        if self.open {
            self.expandIcon?.accessibilityIdentifier = "pgClassic_\(info.productType.rawValue)_header_expandIconOpen"
        } else {
            self.expandIcon?.accessibilityIdentifier = "pgClassic_\(info.productType.rawValue)_header_expandIconClosed"
        }
        
        self.notificationLabel?.accessibilityIdentifier = "pgClassic_\(info.productType.rawValue)_header_movementsValue"
        self.movementLabel?.accessibilityIdentifier = "pgClassic_\(info.productType.rawValue)_header_movementsDesc"
    }
}

extension PGGeneralHeaderView: AccessibilityCapable { }
