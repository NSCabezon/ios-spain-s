import UIKit
import CoreFoundationLib

public class OneSelectorLanguageValueOptionType {
    private let value: String
    public let displayableValue: String
    private var isHighlighted: Bool
    public private(set) var localizedValue: LocalizedStylableText?
    public private(set) var action: (() -> Void)?
    public private(set) var isEnabled: Bool
    public var highlightAction: ((Bool) -> Void)? {
        didSet {
            highlightAction?(isHighlighted)
        }
    }
    
    public init(value: String,
                displayableValue: String,
                localizedValue: LocalizedStylableText? = nil,
                isEnabled: Bool = true,
                isHighlighted: Bool = false,
                action: (() -> Void)? = nil) {
        self.action = action
        self.value = value
        self.displayableValue = displayableValue
        self.localizedValue = localizedValue
        self.isEnabled = isEnabled
        self.highlightAction = nil
        self.isHighlighted = isHighlighted
    }
    
    public func setHighlightedIfMatches(value: String?) {
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
    
    public func setHighlightedIfMatchesString(value: String?) {
        let result = value == self.value
        isHighlighted = result
        highlightAction?(result)
    }
}
