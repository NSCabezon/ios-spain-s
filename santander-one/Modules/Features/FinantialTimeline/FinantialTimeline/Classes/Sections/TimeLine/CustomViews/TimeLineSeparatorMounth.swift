//
//  TimeLineSeparatorMounth.swift
//  FinantialTimeline
//
//  Created by Cristobal Ramos Laina on 22/07/2020.
//

import Foundation

class TimeLineSeparatorMounth: UITableViewCell {

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    var color: UIColor?
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    private func configureView() {
        selectionStyle = .none
        dateLabel.textColor = .lisboaGray
        dateLabel.font = .santanderText(type: .bold, with: 12)
    }
    
    public func setDate(date: String) {
        dateLabel.text = date
    }
    
    public func setBackground(date: Date) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.month], from: date)
        let dateComponentsToday = calendar.dateComponents([.month], from: Date())
        if dateComponents.month ?? 0 > dateComponentsToday.month ?? 0 {
            self.color = .backgroundFutureCell
        } else {
            self.color = .white
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        DispatchQueue.main.async {
            let color: UIColor = self.color ?? .white
            self.contentView.backgroundColor = color
        }
    }
}
