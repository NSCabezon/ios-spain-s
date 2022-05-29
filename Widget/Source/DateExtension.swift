//

import Foundation

extension Date {
    var year: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }
    var month: Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: self)
    }
}
