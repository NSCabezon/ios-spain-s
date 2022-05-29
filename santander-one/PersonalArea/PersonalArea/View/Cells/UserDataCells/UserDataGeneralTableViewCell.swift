//
//  UserDataGeneralTableViewCell.swift
//  PersonalArea
//
//  Created by alvola on 15/01/2020.
//

import UIKit

class UserDataGeneralTableViewCell: UITableViewCell, GeneralPersonalAreaCellProtocol {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var separationView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? UserDataCellModelProtocol else { return }
        titleLabel?.text = info.title
        descriptionLabel?.text = info.description
        
        titleLabel?.accessibilityIdentifier = info.accessibilityTitle
        descriptionLabel?.accessibilityIdentifier = info.accessibilityDescription
        accessibilityIdentifier = info.accessibilityId
    }
    
    private func commonInit() {
        configureView()
        configureLabels()
    }
    
    private func configureView() {
        backgroundColor = UIColor.white
        selectionStyle = .none
        separationView?.backgroundColor = UIColor.mediumSkyGray
    }
    
    private func configureLabels() {
        titleLabel?.font = UIFont.santander(family: .text, type: .light, size: 16.0)
        titleLabel?.textColor = UIColor.lisboaGray
        
        descriptionLabel?.font = UIFont.santander(family: .text, type: .bold, size: 16.0)
        descriptionLabel?.textColor = UIColor.lisboaGray
    }
    
    private func heightWith(_ text: String, _ font: UIFont, _ width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        guard let descriptionLabel = descriptionLabel else { return CGSize(width: targetSize.width, height: 70.0)}
        let height = heightWith(descriptionLabel.text ?? "", descriptionLabel.font, targetSize.width - 30)
        return CGSize(width: targetSize.width, height: max(50.0 + height, 70.0))
    }
}
