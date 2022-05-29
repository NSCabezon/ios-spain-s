//
//  LogoutByePresenter.swift
//  RetailClean
//
//  Created by alvola on 03/04/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//
import CoreFoundationLib


protocol LogoutByePresenterProtocol: class {
    var view: (LogoutByeViewControllerProtocol & UIViewController)? { get set }
    func viewDidLoad()
    func viewDidAppear()
}

final class LogoutByePresenter {
    var view: (LogoutByeViewControllerProtocol & UIViewController)?
    var completeAction: (() -> Void)?
    private let dependenciesResolver: DependenciesResolver?
   
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func presentIn(_ viewController: UIViewController, completeAction: (() -> Void)?) {
        guard let view = view else { return }
        self.completeAction = completeAction
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .coverVertical
        viewController.present(view, animated: true)
    }
}

// MARK: - Private Methods
private extension LogoutByePresenter {
    func createViewModel() -> LogoutByeViewModel {
        let prefixImageName = self.dependenciesResolver?.resolve(forOptionalType: GetLoaderLogoutImagesProtocol.self)?.loaderImageModifier() ?? "bye"
        let randomImageName = prefixImageName+"\(Int.random(in: 1...5))"
        return LogoutByeViewModel(imageName: randomImageName)
    }
}

extension LogoutByePresenter: LogoutByePresenterProtocol {
    func viewDidLoad() {
        view?.configureView(with: createViewModel())
    }
    
    func viewDidAppear() {
        Timer.scheduledTimer(withTimeInterval: 2.0,
                             repeats: false) { [weak self] in
                                $0.invalidate()
                                self?.completeAction?()
        }
    }
}
