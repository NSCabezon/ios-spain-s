import CoreFoundationLib
import Foundation

protocol NoSummaryOperative {
    func getSummaryTitle() -> LocalizedStylableText
    func getSummarySubtitle() -> LocalizedStylableText?
    func getSummaryInfo() -> [SummaryItemData]?
    
    func getAdditionalMessage() -> LocalizedStylableText?
    func getSummaryContinueButtonText() -> LocalizedStylableText?
}

extension NoSummaryOperative {
    func getSummaryTitle() -> LocalizedStylableText {
        return .empty
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        return nil
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return nil
    }
}
