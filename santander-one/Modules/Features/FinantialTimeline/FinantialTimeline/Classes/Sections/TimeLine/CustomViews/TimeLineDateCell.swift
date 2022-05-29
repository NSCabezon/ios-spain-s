//
//  TimeLineDateCell.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 03/07/2019.
//

import Foundation

class TimeLineDateCell: TimeLineCell {
    
    @IBOutlet weak var dateContentView: UIView!
    @IBOutlet weak var dateDayLabel: UILabel!
    @IBOutlet weak var dateMonthLabel: UILabel!
    @IBOutlet weak var topInvoicesView: UIView!
    
    override func configureView() {
        super.configureView()
        dateDayLabel.font = .santanderText(type: .bold, with: 18)
        dateMonthLabel.font = .santanderText(type: .bold, with: 10)
        dateDayLabel.textColor = .lisboaGray
        dateMonthLabel.textColor = .lisboaGray
        dateContentView.layer.borderWidth = 1
        dateContentView.layer.cornerRadius = 5
        dateContentView.layer.borderColor = UIColor.paleSkyBlue.cgColor
        dateContentView.clipsToBounds = true
    }
    
    override func setup(with event: TimeLineEvent, textsEngine: TextsEngine, strategy: TLStrategy?, delegate: TimeLineCellDelegate?) {
        super.setup(with: event, textsEngine: textsEngine, strategy: strategy, delegate: delegate)
        dateDayLabel.text = "\(event.date.getDay())"
        dateMonthLabel.text = event.date.getMonth()
            .replacingOccurrences(of: ".", with: "")
            .uppercased()
    }
}
