import Foundation

class DialogButtonComponents {
    var title: LocalizedStylableText
    var action: (() -> Void)?
    
    init(titled: LocalizedStylableText, does action: (() -> Void)?) {
        self.title = titled
        self.action = action
    }
}
