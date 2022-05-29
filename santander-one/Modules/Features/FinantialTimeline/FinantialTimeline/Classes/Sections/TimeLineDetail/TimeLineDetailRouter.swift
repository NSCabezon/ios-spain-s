//
//  TimeLineDetailRouter.swift
//  Alamofire
//
//  Created by Antonio Muñoz Nieto on 08/07/2019.
//

import Foundation
import UIKit

class TimeLineDetailRouter {
  
    weak var viewController: UIViewController?
    static var pageController: TimeLineDetailPageController?
    
    static func createModule(dependencies: Dependencies, event: TimeLineEvent, delegate: TimeLineDetailDelegate?) -> TimeLineDetailViewController? {
        guard let view = TimeLineDetailViewController.fromStoryBoard() else { return nil }
        let router = TimeLineDetailRouter()
        let interactor = TimeLineDetailInteractor(timeLineRepository: dependencies.timeLineRepository)
        let presenter = TimeLineDetailPresenter(view: view, interactor: interactor, router: router, event: event, textsEngine: dependencies.textsEngine, ctaEngine: dependencies.ctasEngine, dependenciesResolver: dependencies.dependenciesResolver)
        interactor.output = presenter
        view.presenter = presenter
        router.viewController = view
        presenter.delegate = delegate
        return view
    }
    
    static func createModulePeriodicEvent(dependencies: Dependencies, event: PeriodicEvent, delegate: TimeLineDetailDelegate?) -> TimeLineDetailViewController? {
        guard let view = TimeLineDetailViewController.fromStoryBoard() else { return nil }
        let router = TimeLineDetailRouter()
        let interactor = TimeLineDetailInteractor(timeLineRepository: dependencies.timeLineRepository)
        let presenter = CustomEventDetailPresenter(view: view, router: router, event: event, interactor: interactor, ctaEngine: dependencies.ctasEngine, dependenciesResolver: dependencies.dependenciesResolver)
        interactor.output = presenter
        view.presenter = presenter
        router.viewController = view
        presenter.delegate = delegate
        return view
    }
}

// MARK: - UIPager
extension TimeLineDetailRouter {
    class func createModuleWithPager(dependencies: Dependencies, event: TimeLineEvent, delegate: TimeLineDetailDelegate?) -> TimeLineDetailPageController? {
        let storyBoard = UIStoryboard(name: "TimeLineDetail", bundle: .module)
        guard let view = storyBoard.instantiateViewController(withIdentifier: "TimeLineDetailPageController") as? TimeLineDetailPageController,
            let detailController = createModule(dependencies: dependencies, event: event, delegate: delegate) else { return nil }
        pageController = nil
        pageController = view
        pageController?.detailControllers = [detailController]
        return pageController
    }
    
    class func appendPrevious(dependencies: Dependencies, event: TimeLineEvent, delegate: TimeLineDetailDelegate?) {
        guard let detail = createModule(dependencies: dependencies, event: event, delegate: delegate) else { return }
        pageController?.appendPrevious(detail: detail)
    }
    
    class func appendComing(dependencies: Dependencies, event: TimeLineEvent, delegate: TimeLineDetailDelegate?) {
        guard let detail = createModule(dependencies: dependencies, event: event, delegate: delegate) else { return }
        pageController?.appendComing(detail: detail)
    }
    
    class func clearPager(dependencies: Dependencies, event: TimeLineEvent, delegate: TimeLineDetailDelegate?) {
        guard let detail = createModule(dependencies: dependencies, event: event, delegate: delegate) else { return }
        pageController?.clear(with: detail)
    }
}

extension TimeLineDetailRouter: TimeLineDetailWireframeProtocol {
    func dismiss() {
        viewController?.navigationController?.popWithTransition()
    }
    
    func goToTimeline() {
        guard let navigationController = viewController?.navigationController else { return }
        var viewControllersStack = navigationController.viewControllers
        let timelineViewController = viewControllersStack.compactMap { $0 as? TimeLineViewController }.first
        guard let timelinevc = timelineViewController else { return }
        let homeViewController = viewControllersStack[0]
        viewControllersStack = [homeViewController, timelinevc]
        navigationController.view.layer.add(navigationController.fromBottomTransition(), forKey: nil)
        navigationController.setViewControllers(viewControllersStack, animated: false)
    }
    
    func goToEditPeriodicEvent(event: PeriodicEvent) {
        guard let navigationController = viewController?.navigationController else { return }
        let viewControllersStack = navigationController.viewControllers
        let timelineViewController = viewControllersStack.compactMap { $0 as? TimeLineViewController }.first
        guard let presenter = timelineViewController?.presenter as? NewCustomEventDelegate else { return }
        guard let detailView = NewCustomEventRouter.createModule(dependencies: TimeLine.dependencies, periodicEventToEdit: event, delegate: presenter) else { return }
        viewController?.navigationController?.pushWithTransition(viewController: detailView)
    }
}
