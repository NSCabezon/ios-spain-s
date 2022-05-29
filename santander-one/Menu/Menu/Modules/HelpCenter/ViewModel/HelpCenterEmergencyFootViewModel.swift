import Foundation
import CoreFoundationLib

public struct HelpCenterEmergencyFootViewModel {
    let title: LocalizedStylableText
    let isExpanded: Bool
    
    public init(title: LocalizedStylableText, isExpanded: Bool) {
        self.title = title
        self.isExpanded = isExpanded
    }
}
