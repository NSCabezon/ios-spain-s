//
//  NavigationBarState.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/3/21.
//
import CoreFoundationLib
import RxCombine
import OpenCombine
import Foundation

enum NavigationBarState: State {
    case idle
    case menuLoaded((configuration: [MenuTextModel: String], isSearchEnable: Bool))
    case isSearchEnable(Bool)
}

final class NavigationBarViewModel {
    private var subscriptions = Set<AnyCancellable>()
    private let getBarItemUseCase: GetBarItemUseCase
    private let getGlobalSearch: GlobalSearchUsecase

    private var stateSubject = CurrentValueSubject<NavigationBarState, Never>(.idle)
    let state: AnyPublisher<NavigationBarState, Never>

    init(dependencies: NavigationBarDependenciesResolver) {
        self.getBarItemUseCase = dependencies.resolve()
        self.getGlobalSearch = dependencies.resolve()
        self.state = stateSubject.eraseToAnyPublisher()
    }
    
    func loadMenuItems() {
        let menuPublisher = getBarItemUseCase.fechBarItems()
        let searchPublisher = getGlobalSearch.fechGlobalSearch()
        menuPublisher.zip(searchPublisher)
            .subscribe(on: ImmediateScheduler.shared)
            .sink { menuItems in
                self.stateSubject.send(.menuLoaded(menuItems))
            }.store(in: &subscriptions)
    }
}
