//
//  TimeLinePreviousCell.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 10/07/2019.
//

import Foundation

class TimeLinePreviousCell: TimeLineCell {
    
   
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        DispatchQueue.main.async {
            let color: UIColor = highlighted ? .SkyGray : .SkyGray
            self.invoicesContentView.backgroundColor = color
        }
    }
    // For future changes in previous cell 
}
