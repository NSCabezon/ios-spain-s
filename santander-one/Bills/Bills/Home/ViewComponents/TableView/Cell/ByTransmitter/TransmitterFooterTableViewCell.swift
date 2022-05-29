//
//  TransmitterFooterTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/12/20.
//

import UIKit

class TransmitterFooterTableViewCell: UITableViewCell {
    static let identifier = "TransmitterFooterTableViewCell"
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var topLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
        self.viewContainer.backgroundColor = UIColor.skyGray
        self.topLineView.backgroundColor = UIColor.skyGray
        self.viewContainer.drawBorder(cornerRadius: 6, color: .lightSkyBlue, width: 1)
    }
}
