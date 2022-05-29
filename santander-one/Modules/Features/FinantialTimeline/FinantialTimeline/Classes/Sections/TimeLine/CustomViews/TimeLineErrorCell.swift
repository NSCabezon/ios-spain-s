//
//  TimeLineErrorCell.swift
//  Cache
//
//  Created by Antonio Muñoz Nieto on 08/07/2019.
//

import Foundation
import UIKit

class TimeLineErrorCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    func setup(with error: Error) {
        errorLabel.text = error.localizedDescription
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.topaz.cgColor
        errorLabel.textColor = .blueGreen
        errorLabel.font = .santanderText(type: .regular, with: 14)
        errorImage.image = UIImage(fromModuleWithName: "icListError")?.withRenderingMode(.alwaysTemplate)
        errorImage.tintColor = .blueGreen
    }
    
    // MARK: - Private
    
    private func configureView() {
        selectionStyle = .none
    }
}
