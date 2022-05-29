import UIKit

class ValueOptionType {
    let value: String
    let displayableValue: String
    var localizedValue: LocalizedStylableText?
    var action: (() -> Void)?
    var highlightAction: ((Bool) -> Void)? {
        didSet {
            highlightAction?(isHighlighted)
        }
    }
    var isHighlighted: Bool
    
    init(value: String, displayableValue: String, localizedValue: LocalizedStylableText? = nil, isHighlighted: Bool = false, action: (() -> Void)? = nil) {
        self.action = action
        self.value = value
        self.displayableValue = displayableValue
        self.localizedValue = localizedValue
        self.highlightAction = nil
        self.isHighlighted = isHighlighted
    }
    
    func setHighlightedIfMatches(value: String?) {
        var rawText = value?.replacingOccurrences(of: ".", with: "")
        rawText = rawText?.replacingOccurrences(of: ",", with: ".")
        
        guard let value = rawText else {
            highlightAction?(false)
            isHighlighted = false
            return
        }
        let result = Decimal(string: value) == Decimal(string: self.value)
        isHighlighted = result
        highlightAction?(result)
    }
    
    func setHighlightedIfMatchesString(value: String?) {
        let result = value == self.value
        isHighlighted = result
        highlightAction?(result)
    }
}
