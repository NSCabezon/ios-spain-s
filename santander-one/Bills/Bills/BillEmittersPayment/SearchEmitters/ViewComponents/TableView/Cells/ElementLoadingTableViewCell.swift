//
//  ElementLoadingTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/19/20.
//

import UIKit

class ElementLoadingTableViewCell: UITableViewCell {
    static let identifier = "ElementLoadingTableViewCell"
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var boxVeiw: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance()
        self.contentView.isUserInteractionEnabled = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.loadingImageView.setPointsLoader()
        loadingImageView.clipsToBounds = false
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

private extension ElementLoadingTableViewCell {
    func appearance() {
        self.loadingImageView.setPointsLoader()
        self.boxVeiw.backgroundColor = .skyGray
    }
}
