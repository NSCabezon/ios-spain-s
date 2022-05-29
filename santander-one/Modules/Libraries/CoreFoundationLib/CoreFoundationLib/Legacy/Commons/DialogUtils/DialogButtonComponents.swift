import Foundation

public class DialogButtonComponents {
    public var title: LocalizedStylableText
    public let action: (() -> Void)?
    
    public init(titled: LocalizedStylableText, does action: (() -> Void)?) {
        self.title = titled
        self.action = action
    }
}
