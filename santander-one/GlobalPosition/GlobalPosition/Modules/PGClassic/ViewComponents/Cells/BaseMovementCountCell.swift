//
//  BaseMovementCountCell.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 03/04/2020.
//

import Foundation
import CoreFoundationLib

class BaseMovementCountCell: UITableViewCell {
    @IBOutlet weak var movementLabel: UILabel?
    @IBOutlet weak var notificationLabel: UILabel?
    @IBOutlet weak var verticalLine: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    public func configureCellWith(_ info: Any?) {
        if let info = info as? PGGeneralCellViewModelProtocol {
            notificationLabel?.text = String(info.notification ?? 0)
            if let movCount = info.notification, movCount > 0 {
                notificationLabel?.text = String(movCount)
                notificationLabel?.isHidden = false
                movementLabel?.isHidden = false
                verticalLine?.isHidden = false
            let localizedText = (movCount > 1) ?
                PGCommonTexts.localizableTextForElement(.classicGeneralProductCell(.plural)) :
                PGCommonTexts.localizableTextForElement(.classicGeneralProductCell(.singular))
                movementLabel?.configureText(withLocalizedString: localizedText)
            } else {
                notificationLabel?.isHidden = true
                movementLabel?.isHidden = true
                verticalLine?.isHidden = true
            }
        }
    }
}

private extension BaseMovementCountCell {
    func configureUI() {
        verticalLine?.backgroundColor = .brownGray
        movementLabel?.textColor = .brownGray
        movementLabel?.font = .santander(family: .text, type: .regular, size: 14.0)
        notificationLabel?.font = .santander(family: .text, type: .bold, size: 14.0)
        notificationLabel?.textColor = .santanderRed
    }
}
