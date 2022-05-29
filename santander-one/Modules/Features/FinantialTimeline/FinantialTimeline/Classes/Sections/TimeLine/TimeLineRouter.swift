//
//  TimeLineRouter.swift
//  FinantialTimeline
//
//  Created by Antonio Muñoz Nieto on 28/06/2019.
//

import Foundation
import UIKit

class TimeLineRouter {
    
    weak var viewController: UIViewController?
    
    static func createModule(dependencies: Dependencies) -> TimeLineViewController? {
        guard let view = TimeLineViewController.fromStoryBoard() else { return nil }
        let interactor = TimeLineInteractor(timeLineRepository: dependencies.timeLineRepository)
        let router = TimeLineRouter()
        let presenter = TimeLinePresenter(interface: view, interactor: interactor, router: router, configurationEngine: dependencies.configurationEngine, textsEngine: dependencies.textsEngine, dependenciesResolver: dependencies.dependenciesResolver)
        view.textsEngine = dependencies.textsEngine
        view.presenter = presenter
        view.strategy = TimeLineListStrategy(view: view)
        interactor.output = presenter
        router.viewController = view
        return view
    }
    
    static func createWidgetModule(dependencies: Dependencies, days: Int, elements: Int) -> UIView? {
        guard let view = TimeLineViewController.fromStoryBoard() else { return nil }
        let interactor = TimeLineInteractor(timeLineRepository: dependencies.timeLineRepository)
        let router = TimeLineRouter()
        let presenter = TimeLinePresenter(interface: view, interactor: interactor, router: router, configurationEngine: dependencies.configurationEngine, textsEngine: dependencies.textsEngine, dependenciesResolver: dependencies.dependenciesResolver)
        view.textsEngine = dependencies.textsEngine
        view.presenter = presenter
        view.strategy = TimeLineWidgetStrategy(view: view, numEvents: elements, numDays: days)
        interactor.output = presenter
        router.viewController = view
        return view.view
    }
    
    static func createHybridModule(dependencies: Dependencies) -> HybridTimeLineController? {
        guard let view = HybridTimeLineController.fromStoryBoard() else { return nil }
        view.dependencies = dependencies
        return view
    }
}

extension TimeLineRouter: TimeLineWireframeProtocol {
    
    func loadTimeLineEventDetail(_ event: TimeLineEvent) {
        let timelineVC = viewController as? TimeLineViewController
        let delegate = timelineVC?.presenter as? TimeLineDetailDelegate
        guard let destinationViewController = TimeLineDetailRouter.createModuleWithPager(dependencies: TimeLine.dependencies, event: event, delegate: delegate) else { return }
        viewController?.navigationController?.pushWithTransition(viewController: destinationViewController)
    }
    
    func loadNewCustomEvent() {
        guard let destinationViewController = NewCustomEventRouter.createModule(dependencies: TimeLine.dependencies, periodicEventToEdit: nil, delegate: nil) else { return }
        viewController?.navigationController?.pushWithTransition(viewController: destinationViewController)
    }
    
    func exportEventsToCalendar() {
        guard let destinationViewController = ExportEventRouter.createModule(dependencies: TimeLine.dependencies) else { return }
        viewController?.navigationController?.pushWithTransition(viewController: destinationViewController)
    }
    
    func goToSettings(with delegate: TimeLineDetailDelegate) {
        guard let destinationViewController = SetupRouter.createModule(dependencies: TimeLine.dependencies, with: delegate) else { return }
        viewController?.navigationController?.pushWithTransition(viewController: destinationViewController)
    }
    
    func loadCustomEvents() {
        guard let customEventsViewController = CustomEventsRouter.createModule(dependencies: TimeLine.dependencies) else { return }
        viewController?.navigationController?.pushWithTransition(viewController: customEventsViewController)
    }
    
    func dismiss() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}


