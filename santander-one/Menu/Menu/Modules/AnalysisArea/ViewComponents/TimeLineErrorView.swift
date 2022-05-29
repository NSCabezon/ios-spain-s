//
//  TimeLineErrorView.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 25/03/2020.
//

import UI
import CoreFoundationLib

class TimeLineErrorView: UIView {
    @IBOutlet weak var backgroudImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    public func setTitle(_ localizedTitle: LocalizedStylableText) {
        self.titleLabel.configureText(withLocalizedString: localizedTitle)
    }
    
    public func setSubTitle(_ localizedTitle: LocalizedStylableText) {
         self.subTitleLabel.configureText(withLocalizedString: localizedTitle)
     }
    
    private func configureUI() {
        self.titleLabel.font = UIFont.santander(family: .headline, type: .regular, size: 18.0)
        self.titleLabel.textColor = UIColor.lisboaGray
        self.subTitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        self.subTitleLabel.textColor = UIColor.lisboaGray
        self.backgroudImageView.image = Assets.image(named: "imgLeaves")
    }
}
