//
//  OpeningHoursCell.swift
//  BranchLocator
//
//  Created by Tarsha De Souza on 27/06/2019.
//

import UIKit

class OpeningHoursCell: UITableViewCell {

    
    @IBOutlet var openHoursLbl: UILabel! {
        didSet{
            openHoursLbl.font = DetailCardCellAndViewThemeFont.closingInLabel.value
            openHoursLbl.textColor = DetailCardCellAndViewThemeColor.closingInLabel.value
        }
    }
    @IBOutlet var circleView: UIView! {
        didSet{
            circleView.layer.cornerRadius = circleView.frame.size.width/2
            circleView.clipsToBounds = true
        }
    }
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
        selectionStyle = .none
    }

    func configure(openingHours: String, circleColor: UIColor) {
        openHoursLbl.text = openingHours
        circleView.backgroundColor = circleColor
    }
 

}
