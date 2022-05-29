//
//  TimeLineNotTodayCell.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 19/08/2019.
//

import Foundation
import UIKit

class TimeLineNotTodayCell: TimeLineCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var todayContentView: UIView!
    @IBOutlet weak var todayLabel: UILabel!
    
    override func configureView() {
        super.configureView()
        isUserInteractionEnabled = false
        setTodayView()
        setInvoiceView()
    }
    
    func setTodayView() {
        todayLabel.text = TimeLineString().today
        todayLabel.font = .santanderText(type: .bold, with: 17)
        todayLabel.textColor = .lisboaGray
        todayContentView.layer.borderColor = UIColor.mediumSky.cgColor
        todayContentView.backgroundColor = .iceBlue
        todayContentView.layer.borderWidth = 1
        todayContentView.layer.cornerRadius = 5
    }
    
    func setInvoiceView() {
        shortDescriptionTextView.font = .santanderText(type: .regular, with: 14)
        shortDescriptionTextView.textColor = .blueGreen
        invoicesContentView.backgroundColor = .iceBlue
        dateLabel.textColor = .lisboaGray
        dateLabel.font = .santanderText(type: .bold, with: 12)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        DispatchQueue.main.async {
            let color: UIColor = highlighted ? .sky30 : .sky30
            self.invoicesContentView.backgroundColor = color
        }
    }
    
    func setNoEventsToday() {
        shortDescriptionTextView.text = TimeLineString().noEventToday
    }
    
    public func setDate(date: String) {
        dateLabel.text = date
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        super.drawBorder()
    }
}
