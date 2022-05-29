//
//  SetupRouter.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 27/09/2019.
//

import Foundation

class SetupRouter {
    weak var viewController: UIViewController?
       
    class func createModule(dependencies: Dependencies, with delegate: TimeLineDetailDelegate) -> SetupViewController? {
        guard let view = SetupViewController.fromStoryBoard() else { return nil }
        let router = SetupRouter()
        let interactor = SetupInteractor(timeLineRepository: dependencies.timeLineRepository)
        let presenter = SetupPresenter(view: view, interactor: interactor, router: router, textEngine: dependencies.textsEngine, delegate: delegate)
        interactor.output = presenter
        view.presenter = presenter
        router.viewController = view
        
        return view
    }
}

extension SetupRouter: SetupRouterProtocol {
    func dismiss() {
        viewController?.navigationController?.popWithTransition()
    }
}
