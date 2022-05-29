import Foundation
import CoreFoundationLib

class TutorialDetailPresenter: PrivatePresenter<TutorialDetailViewController, VoidNavigator, TutorialDetailPresenterProtocol> {
    let tutorialDetail: TutorialPage
    
    init(tutorialDetail: TutorialPage, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: VoidNavigator) {
        self.tutorialDetail = tutorialDetail
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        let sectionContent = TableModelViewSection()
        
        if let banner = tutorialDetail.banner {
            let imageModel = TutorialImageTableViewModel(url: banner.url, actionDelegate: self, dependencies: dependencies)
            sectionContent.items.append(imageModel)
            let separator = OperativeSeparatorModelView(insets: Insets(left: 0, right: 0, top: 0, bottom: 0), privateComponent: dependencies)
            sectionContent.items.append(separator)
        }
        if let title = tutorialDetail.title {
            let titleLabelModel = OperativeLabelTableModelView(title: LocalizedStylableText(text: title, styles: nil), style: LabelStylist(textColor: .sanRed, font: .latoSemibold(size: 20), textAlignment: .center), insets: Insets(left: 0, right: 0, top: 10, bottom: 15), privateComponent: dependencies)
            sectionContent.items.append(titleLabelModel)
        }
        if let desc = tutorialDetail.description {
            let descLabelModel = OperativeLabelTableModelView(title: LocalizedStylableText(text: desc, styles: nil), style: LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 16), textAlignment: .center), insets: Insets(left: 20, right: 19, top: 0, bottom: 10), privateComponent: dependencies)
            sectionContent.items.append(descLabelModel)
        }
        view.sections = [sectionContent]
    }
}

// MARK: - TutorialPresenterProtocol
extension TutorialDetailPresenter: TutorialDetailPresenterProtocol {}

extension TutorialDetailPresenter: TutorialImageTableViewModelDelegate {
    func finishDownloadImage() {
        view.calculateHeight()
    }
}
