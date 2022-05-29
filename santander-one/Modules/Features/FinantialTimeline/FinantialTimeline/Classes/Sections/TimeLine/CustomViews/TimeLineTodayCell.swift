//
//  TimeLineTodayCell.swift
//  FinantialTimeline
//
//  Created by Antonio Muñoz Nieto on 04/07/2019.
//

import Foundation
import UIKit

class TimeLineTodayCell: TimeLineCell {
    @IBOutlet weak var todayDateLabel: UILabel!
    @IBOutlet weak var todayContentView: UIView!
    @IBOutlet weak var todayLabel: UILabel!
    
    override func configureView() {
        super.configureView()
        todayLabel.font = .santanderText(type: .bold, with: 17)
        todayContentView.layer.borderWidth = 1
        todayLabel.textColor = .lisboaGray
        todayContentView.layer.borderColor = UIColor.mediumSky.cgColor
        todayContentView.backgroundColor = .iceBlue
        todayContentView.layer.cornerRadius = 5
        todayLabel.text = TimeLineString().today
        todayDateLabel.textColor = .lisboaGray
        todayDateLabel.font = .santanderText(type: .bold, with: 12)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        DispatchQueue.main.async {
            let color: UIColor = highlighted ? .iceBlue : .iceBlue
            self.invoicesContentView.backgroundColor = color
        }
    }
    
    public func setDate(date: String) {
        todayDateLabel.text = date
    }
}
