//
//  ExportEventRouter.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 23/09/2019.
//

import Foundation

class ExportEventRouter {
    weak var viewController: UIViewController?
    
    class func createModule(dependencies: Dependencies) -> ExportEventViewController? {
        guard let view = ExportEventViewController.fromStoryBoard() else { return nil }
        let router = ExportEventRouter()
        let interactor = ExportEventInteractor(repository: dependencies.timeLineRepository)
        let presenter = ExportEventPresenter(view: view, interactor: interactor, router: router, textEngine: dependencies.textsEngine)
        interactor.output = presenter
        view.presenter = presenter
        router.viewController = view
        
        return view
    }
}

extension ExportEventRouter: ExportEventRouterProtocol {
    func dismiss() {
        viewController?.navigationController?.popWithTransition()
    }
}
