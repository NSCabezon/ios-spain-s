//
//  MovementTableViewCell.swift
//  toTest
//
//  Created by alvola on 08/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import UI

final class MovementTableViewCell: OldGeneralProductTableViewCell {

    @IBOutlet weak var separationView: DottedLineView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateFonts()
    }
    
    override func setCellInfo(_ info: Any?) {
        super.setCellInfo(info)
        if let info = info as? PGMovementCellViewModel {
            titleLabel?.font = UIFont.santander(family: .text, type: info.imNew ? .bold : .regular, size: 15.0)
            separationView?.isHidden = info.imLast
        }
    }

    private func updateFonts() {
        titleLabel?.font = UIFont.santander(family: .text, size: 15.0)
        subtitleLabel?.font = subtitleLabel?.font.withSize(14.0)
        valueLabel?.font = titleLabel?.font.withSize(18.0)
    }
    
    override func configureView() {
        selectionStyle = .none
        separationView?.backgroundColor = UIColor.clear
        frameView?.backgroundColor = UIColor.clear
        frameView?.frameBackgroundColor = UIColor.white.cgColor
        frameView?.layer.cornerRadius = 6.0
        frameView?.layer.borderWidth = 0.0
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 72.0)
    }
}
