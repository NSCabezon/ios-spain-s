//
//  TimeLinePreviousDateCell.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 10/07/2019.
//

import Foundation

class TimeLinePreviousDateCell: TimeLineDateCell {
    @IBOutlet weak var topBorderView: UIView!
    @IBOutlet weak var upToArrow: UIView!
    @IBOutlet weak var downToArrowView: UIView!
    @IBOutlet weak var bottomBorderView: UIView!
    @IBOutlet weak var traillingBorderView: UIView!
 
    override func configureView() {
        dateDayLabel.font = .santanderText(type: .bold, with: 18)
        dateMonthLabel.font = .santanderText(type: .bold, with: 10)
        dateContentView.layer.borderWidth = 1
        dateContentView.layer.cornerRadius = 5
        dateContentView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        dateContentView.clipsToBounds = true
        dateDayLabel.textColor = .mediumSanGray
        dateMonthLabel.textColor = .mediumSanGray
        dateContentView.backgroundColor = .SkyGray
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        DispatchQueue.main.async {
            let color: UIColor = highlighted ? .SkyGray : .SkyGray
            self.invoicesContentView.backgroundColor = color
        }
    }
}
