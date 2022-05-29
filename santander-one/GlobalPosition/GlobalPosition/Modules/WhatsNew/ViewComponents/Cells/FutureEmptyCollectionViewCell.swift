//
//  FutureEmptyCollectionViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//

import UIKit
import CoreFoundationLib
import UI

class FutureEmptyCollectionViewCell: UICollectionViewCell {
    static let identifier = "FutureEmptyCollectionViewCell"
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emptyImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance()
    }
    
    private func appearance() {
        self.emptyImageView.image = Assets.image(named: "icnReceipt")
        self.viewContainer.drawBorder(cornerRadius: 5, color: .skyGray, width: 1)
        self.viewContainer.backgroundColor = .skyGray
        self.descriptionLabel.configureText(withKey: "receiptsAndTaxes_textEmpty_nextReceipts", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        self.descriptionLabel.textColor = .lisboaGray
    }
}
