//
//  OperativeCoordinator.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 5/1/22.
//

import OpenCombine
import UI

public protocol OperativeCoordinator: BindableCoordinator, LoadingViewPresentationCapable, DialogViewPresentationCapable, OldDialogViewPresentationCapable, JumpingGreenCirclesLoadingViewPresentationCapable {
    var opinatorCoordinator: BindableCoordinator { get }
    func next()
    func back()
    func resetOperative()
    func goToGlobalPosition()
}

extension OperativeCoordinator {
    public var associatedLoadingView: UIViewController {
        return navigationController ?? UIViewController()
    }
    
    public var associatedDialogView: UIViewController {
        return associatedLoadingView
    }
    
    public var associatedOldDialogView: UIViewController {
        return associatedLoadingView
    }

    public func resetOperative() {}
}
