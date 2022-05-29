//
//  NewCustomEventRouter.swift
//  FinantialTimeline-FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 04/09/2019.
//

import UIKit

class NewCustomEventRouter {
    weak var viewController: UIViewController?
    static func createModule(dependencies: Dependencies, periodicEventToEdit: PeriodicEvent?, delegate: NewCustomEventDelegate?) -> NewCustomEventViewController? {
        guard let view = NewCustomEventViewController.fromStoryBoard() else { return nil }
        let interactor = NewCustomEventInteractor(timeLineRepository: dependencies.timeLineRepository)
        let router = NewCustomEventRouter()
        let presenter = NewCustomEventPresenter(view: view, router: router, interactor: interactor, periodicEventToEdit: periodicEventToEdit)
        presenter.delegate = delegate
        view.presenter = presenter
        router.viewController = view
        return view
    }
}


extension NewCustomEventRouter: NewCustomEventWireframeProtocol {
    func dismiss() {
        viewController?.navigationController?.popWithTransition()
    }
    
    func loadTimeLineEventDetail(_ event: TimeLineEvent) {
        guard let navigationController = viewController?.navigationController else { return }
        var viewControllersStack = navigationController.viewControllers
        let timelinepresenter = viewControllersStack.compactMap { $0 as? TimeLineViewController }.first?.presenter as? TimeLineDetailDelegate
        guard let destinationViewController = TimeLineDetailRouter.createModule(dependencies: TimeLine.dependencies, event: event, delegate: timelinepresenter) else { return }
        viewControllersStack[viewControllersStack.count - 1] = destinationViewController
        navigationController.view.layer.add(navigationController.fromBottomTransition(), forKey: nil)
        navigationController.setViewControllers(viewControllersStack, animated: false)
    }
    
    func loadTimeLine() {
        guard let navigationController = viewController?.navigationController else { return }
        var viewControllersStack = navigationController.viewControllers
        let timelineViewController = viewControllersStack.compactMap { $0 as? TimeLineViewController }.first
        guard let timelinevc = timelineViewController else { return }
        let homeViewController = viewControllersStack[0]
        viewControllersStack = [homeViewController, timelinevc]
        navigationController.view.layer.add(navigationController.fromBottomTransition(), forKey: nil)
        navigationController.setViewControllers(viewControllersStack, animated: false)
    }
    
    func showAlert(error: Error) {
        let title = IBLocalizedString("timeline.newcustomeventSection.event.error.title")
        let subtitle = IBLocalizedString("timeline.newcustomeventSection.event.error.subtitle")
        let accept = IBLocalizedString("timeline.newcustomeventSection.event.error.accept")
        let alert = GlobileAlertController(title: title, subtitle: subtitle, actions: [])
        let acceptAction = GlobileAlertAction(title: accept, style: .primary, action: {alert.dismiss(animated: true, completion: nil)})
        alert.addAction(acceptAction)
        alert.modalPresentationStyle = .overCurrentContext
        viewController?.present(alert, animated: true)        
    }
}
