//

import Foundation

class TransactionDaySection: TableModelViewSection {
    
    let date: Date?
    
    init(date: Date?) {
        self.date = date
        super.init()
        isCollapsible = false
    }
    
}
