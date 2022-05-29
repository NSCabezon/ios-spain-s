//
//  ExpensesAnalysysConfigHeaderViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 13/7/21.
//

import CoreFoundationLib

struct ExpensesAnalysysConfigHeaderViewModel {
    private let date: Date
    private let timeManager: TimeManager
    
    init(timeManager: TimeManager, date: Date) {
        self.timeManager = timeManager
        self.date = date
    }
    
    private var formattedDate: String {
        return self.timeManager.toString(date: self.date, outputFormat: .eeee_HHmm) ?? ""
    }
    
    private var placeholder: [StringPlaceholder] {
        return [StringPlaceholder(.date, self.formattedDate)]
    }
    
    var lastUpdateText: LocalizedStylableText {
        return localized("analysis_label_lastUpdate", self.placeholder)
    }
}
