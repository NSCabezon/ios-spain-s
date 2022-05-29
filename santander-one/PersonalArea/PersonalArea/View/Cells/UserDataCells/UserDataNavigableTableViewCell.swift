//
//  UserDataNavigableTableViewCell.swift
//  PersonalArea
//
//  Created by alvola on 15/01/2020.
//

import UIKit
import UI
import CoreFoundationLib

class UserDataNavigableTableViewCell: UITableViewCell, GeneralPersonalAreaCellProtocol {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var separationView: UIView?
    @IBOutlet weak var goToIcon: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? UserDataCellModelProtocol else { return }
        titleLabel?.text = info.title
        descriptionLabel?.text = info.description
        self.setAccessibilityIdentifiers(info)
    }
    
    private func commonInit() {
        configureView()
        configureLabels()
    }
    
    private func configureView() {
        backgroundColor = UIColor.white
        selectionStyle = .none
        separationView?.backgroundColor = UIColor.mediumSkyGray
        goToIcon?.image = Assets.image(named: "icnArrowRightGray")
    }
    
    private func configureLabels() {
        titleLabel?.font = UIFont.santander(family: .text, size: 16.0)
        titleLabel?.textColor = UIColor.lisboaGray
        
        descriptionLabel?.font = UIFont.santander(family: .text, size: 14.0)
        descriptionLabel?.textColor = UIColor.lisboaGray
    }
    
    private func setAccessibilityIdentifiers(_ info: UserDataCellModelProtocol) {
        self.titleLabel?.accessibilityIdentifier = info.accessibilityTitle
        self.descriptionLabel?.accessibilityIdentifier = info.accessibilityDescription
        self.accessibilityIdentifier = info.accessibilityId
        self.goToIcon?.accessibilityIdentifier = info.accessibilityBtn
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 70.0)
    }
}
