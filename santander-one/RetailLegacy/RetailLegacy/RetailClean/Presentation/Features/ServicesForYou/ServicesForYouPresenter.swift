import UIKit
import CoreFoundationLib

class ServicesForYouPresenter: PrivatePresenter<ServicesForYouViewController, PrivateHomeNavigator & PrivateHomeNavigatorSideMenu, ServicesForYouPresenterProtocol> {
    let category: Category
    
    init(category: Category, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: PrivateHomeNavigator & PrivateHomeNavigatorSideMenu) {
        self.category = category
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        guard let title = self.category.name, let imageURL = self.category.imageRelativeURL else { return }
        view.styledTitle = LocalizedStylableText(text: title, styles: nil)
        
        let sectionHeader = TableModelViewSection()
        let imageModel = ImageTableViewModel(url: imageURL, actionDelegate: self, dependencies: dependencies)
        let separatorViewCell = OperativeSeparatorModelView(heightSepartor: 10.0, color: .background, insets: Insets(left: 0, right: 0, top: 0, bottom: 0), privateComponent: dependencies)
        sectionHeader.items += [imageModel, separatorViewCell]
        
        let sectionContent = TableModelViewSection()
        guard let items = self.category.items else { return }
        for item in items {
            let itemModel = ItemTableViewModel(title: item.name, link: item.link, dependencies: dependencies)
            sectionContent.items.append(itemModel)
        }
        view.sections = [sectionHeader, sectionContent]
    }
}

extension ServicesForYouPresenter: ServicesForYouPresenterProtocol {    
    func actionSelectedCell(index: Int) {
        guard let modelView = view.itemsSectionContent()[index] as? ItemTableViewModel else {
            return
        }
        if let link = modelView.link, let url = URL(string: link) {
            navigator.open(url)
        }
    } 
}

extension ServicesForYouPresenter: SideMenuCapable {
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension ServicesForYouPresenter: ImageTableViewModelDelegate {
    func finishDownloadImage() {
        view.calculateHeight()
    }
}
