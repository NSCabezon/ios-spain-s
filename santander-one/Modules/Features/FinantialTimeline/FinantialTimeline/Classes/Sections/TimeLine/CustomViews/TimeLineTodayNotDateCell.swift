//
//  TimeLineTodayNotDateCell.swift
//  FinantialTimeline
//
//  Created by Cristobal Ramos Laina on 31/07/2020.
//

import Foundation

class TimeLineTodayNotDateCell: TimeLineCell {
    
   
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        DispatchQueue.main.async {
            let color: UIColor = highlighted ? .iceBlue : .iceBlue
            self.invoicesContentView.backgroundColor = color
        }
    }
    // For future changes in previous cell
}
