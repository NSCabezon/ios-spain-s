//
//  DigitalProfileOptionTableViewCell.swift
//  PersonalArea
//
//  Created by alvola on 05/12/2019.
//

import UIKit
import CoreFoundationLib
import UI

class DigitalProfileOptionTableViewCell: UITableViewCell, GeneralPersonalAreaCellProtocol {
    @IBOutlet weak var checkImage: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var goToImage: UIImageView?
    @IBOutlet weak var separationView: DottedLineView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? DigitalProfileCellModel else { return }
        titleLabel?.text = localized(info.title)
        titleLabel?.accessibilityIdentifier = info.accassibilityIdentifier
        separationView?.isHidden = info.done
        goToImage?.isHidden = info.done
        checkImage?.image = Assets.image(named: info.done ? "icnCheckGreen" : "icnCheckGrey")
    }
    
    private func commonInit() {
        selectionStyle = .none
        checkImage?.image = Assets.image(named: "icnCheckGrey")
        titleLabel?.font = UIFont.santander(family: .text, size: 16.0)
        titleLabel?.textColor = UIColor.lisboaGray
        goToImage?.image = Assets.image(named: "icnArrowRightGray")
        separationView?.strokeColor = UIColor.mediumSkyGray
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 48.0)
    }
}
