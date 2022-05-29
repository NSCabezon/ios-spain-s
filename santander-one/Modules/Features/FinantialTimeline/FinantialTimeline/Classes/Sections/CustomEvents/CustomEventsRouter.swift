//
//  CustomEventsRouter.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 10/10/2019.
//

import Foundation

class CustomEventsRouter {
  
    weak var viewController: UIViewController?
    
    static func createModule(dependencies: Dependencies) -> CustomEventsViewController? {
        let view = CustomEventsViewController()
        let router = CustomEventsRouter()
        let interactor = CustomEventsInteractor(timeLineRepository: dependencies.timeLineRepository)
        let presenter = CustomEventsPresenter(view: view, router: router, interactor: interactor)
        
        
        view.presenter = presenter
        router.viewController = view
        interactor.output = presenter
        
        
        return view
    }
}


extension CustomEventsRouter: CustomEventsWireframeProtocol {
    
    func dismiss() {
        viewController?.navigationController?.popWithTransition()
    }
    
    func showDetailView(_ event: PeriodicEvent) {
        guard let navigationController = viewController?.navigationController else { return }
        let viewControllersStack = navigationController.viewControllers
        let timelinepresenter = viewControllersStack.compactMap { $0 as? TimeLineViewController }.first?.presenter as? TimeLineDetailDelegate
        guard let detailView = TimeLineDetailRouter.createModulePeriodicEvent(dependencies: TimeLine.dependencies, event: event, delegate: timelinepresenter) else { return }
        viewController?.navigationController?.pushWithTransition(viewController: detailView)
    }
    
    func showNewCustomEvent() {
        guard let destinationViewController = NewCustomEventRouter.createModule(dependencies: TimeLine.dependencies, periodicEventToEdit: nil, delegate: nil) else { return }
        guard var viewControllers = viewController?.navigationController?.viewControllers else { return }
        _ = viewControllers.popLast()
        viewControllers.append(destinationViewController)
        viewController?.navigationController?.setViewControllersWithTransition(viewControllers: viewControllers)
    }

}
