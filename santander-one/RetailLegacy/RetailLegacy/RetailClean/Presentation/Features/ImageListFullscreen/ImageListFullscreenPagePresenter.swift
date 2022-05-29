import Foundation
import CoreFoundationLib

class ImageListFullscreenPagePresenter: PrivatePresenter<ImageListFullscreenPageViewController, VoidNavigator, ImageListFullscreenPagePresenterProtocol> {
    private let page: ListPageDTO
    
    init(page: ListPageDTO, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: VoidNavigator) {
        self.page = page
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        dependencies.imageLoader.loadWithAspectRatioGIF(absoluteUrl: page.imageFullscreen, imageView: view.imageView, placeholderIfDoesntExist: nil, completion: nil)
    }
}

extension ImageListFullscreenPagePresenter: ImageListFullscreenPagePresenterProtocol {}
