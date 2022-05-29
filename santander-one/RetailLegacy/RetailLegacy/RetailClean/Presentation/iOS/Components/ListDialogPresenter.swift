import Foundation
import CoreFoundationLib

enum ListDialogItem {
    
    struct Margin {
        
        let top: Float
        let left: Float
        let right: Float
        
        static func zero() -> Margin {
            return Margin(top: 0, left: 0, right: 0)
        }
        
        static func left(_ left: Float) -> Margin {
            return Margin(top: 0, left: left, right: 0)
        }
    }
    
    case text(String)
    case styledText(String, LabelStylist)
    case listItem(String, margin: Margin)
}

enum ListDialogType {
    case withoutButton
    case withButton(LocalizedStylableText)
}

class ListDialogPresenter: PrivatePresenter<ListDialogViewController, ListDialogNavigator, ListDialogPresenterProtocol> {
    
    // MARK: - Private attributes
    
    private let items: [ListDialogItem]
    private let title: LocalizedStylableText
    private let type: ListDialogType
    
    // MARK: - Public methods
    
    init(title: LocalizedStylableText, items: [ListDialogItem], type: ListDialogType, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: ListDialogNavigator) {
        self.items = items
        self.title = title
        self.type = type
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.show(items: localized(items: items))
        view.show(title: title)
        switch type {
        case .withoutButton:
            view.setCloseButtonHidden(false)
            view.setBottomButtonHidden(true)
        case .withButton(let buttonTitle):
            view.setCloseButtonHidden(true)
            view.setBottomButtonHidden(false)
            view.setBottomButtonTitle(buttonTitle)
        }
    }
    
    // MARK: - Private methods
    
    private func localized(items: [ListDialogItem]) -> [ListDialogItemViewModel] {
        return items.map({ ListDialogItemViewModel(dependencies: dependencies, item: $0) })
    }
}

extension ListDialogPresenter: ListDialogPresenterProtocol {
    
    func didSelectClose() {
        navigator.dismiss()
    }
}
