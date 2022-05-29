//
//  DigitalProfileHeaderTableViewCell.swift
//  PersonalArea
//
//  Created by alvola on 10/12/2019.
//

import UIKit
import UI
import CoreFoundationLib

class DigitalProfileHeaderTableViewCell: UITableViewCell, GeneralPersonalAreaCellProtocol {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var separationView: DottedLineView?
    @IBOutlet weak var centerConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? DigitalProfileCellModel else { return }
        titleLabel?.text = info.title
        titleLabel?.accessibilityIdentifier = info.accassibilityIdentifier
        separationView?.isHidden = info.done
        centerConstraint?.constant = info.done ? 0.0 : 10.0
    }
    
    private func commonInit() {
        selectionStyle = .none
        titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 18.0)
        titleLabel?.textColor = UIColor.lisboaGray
        separationView?.strokeColor = UIColor.mediumSkyGray
    }
 
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 65.0)
    }
}
