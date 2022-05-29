import Foundation

class ListDialogItemViewModel {
    
    enum ListDialogLocalizedItem {
        case text(LocalizedStylableText)
        case styledText(LocalizedStylableText, LabelStylist)
        case listItem(LocalizedStylableText, ListDialogItem.Margin)
    }
    
    private let dependencies: PresentationComponent
    private let item: ListDialogItem
    
    init(dependencies: PresentationComponent, item: ListDialogItem) {
        self.dependencies = dependencies
        self.item = item
    }
    
    var localizedItem: ListDialogLocalizedItem {
        switch item {
        case .text(let text):
            return .text(dependencies.stringLoader.getString(text))
        case .styledText(let text, let style): return .styledText(dependencies.stringLoader.getString(text), style)
        case .listItem(let text, let margin):
            return .listItem(dependencies.stringLoader.getString(text), margin)
        }
    }
}
