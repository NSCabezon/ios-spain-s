//
//  LoadingTipPresenter.swift
//  UI
//
//  Created by Luis Escámez Sánchez on 10/02/2020.
//

import CoreFoundationLib

public protocol LoadingTipPresenterProtocol {
    var view: LoadingTipViewProtocol? { get set }
    func viewDidLoad()
}

final public class LoadingTipPresenter {
    
    private let dependenciesResolver: DependenciesResolver
    public var view: LoadingTipViewProtocol?
    
    private var getTipsUseCase: GetLoadingTipsUseCase {
        return dependenciesResolver.resolve(for: GetLoadingTipsUseCase.self)
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension LoadingTipPresenter: LoadingTipPresenterProtocol {
    
    public func viewDidLoad() {
        loadTips()
    }
}

// MARK: - Private Methods
private extension LoadingTipPresenter {
    
    func loadTips() {
        MainThreadUseCaseWrapper(with: getTipsUseCase, onSuccess: { [weak self] response in
            self?.showRandomTip(for: response)
            }, onError: { [weak self] _ in
                self?.showScreenWithNoRandomTip()
        })
    }
    
    func showRandomTip(for response: GetLoadingTipsUseCaseOutput?) {
        guard let selectedLoadingTip = response?.tipsList.randomElement(),
            let selectedImageTipName = response?.imageNamesLists.randomElement() else {
                return
        }
        
        self.view?.configureView(with: LoadingTipViewModel(imageName: selectedImageTipName,
                                                           title: selectedLoadingTip.title,
                                                           mainTitle: selectedLoadingTip.mainTitle,
                                                           boldTitle: selectedLoadingTip.boldTitle,
                                                           subtitle: selectedLoadingTip.subtitle)
        )
    }
    
    func showScreenWithNoRandomTip() {
        self.view?.configureView(with: nil)
    }
}
