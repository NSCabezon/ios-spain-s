//
//  OneFavouritesListViewModel.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 4/1/22.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain
import UI

enum OneFavouritesListState: State {
    case idle
    case contactsLoaded([PayeeRepresentable], SepaInfoListRepresentable?)
    case empty(FavouriteContactsEmptyType)
}

final class OneFavouritesListViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: OneFavouritesListDependenciesResolver
    private let stateSubject = CurrentValueSubject<OneFavouritesListState, Never>(.idle)
    var state: AnyPublisher<OneFavouritesListState, Never>
    
    init(dependencies: OneFavouritesListDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        loadFavoritesListInfo()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    func showHelp() {
        coordinator.showHelp()
    }
    
    func close() {
        coordinator.dismiss()
    }
}

private extension OneFavouritesListViewModel {
    var coordinator: OneFavouritesListCoordinator {
        return dependencies.resolve()
    }
    
    var getFavoritesUseCase: GetReactiveContactsUseCase {
        return dependencies.external.resolve()
    }
    
    var getSepaInfoUseCase: GetSepaInfoListUseCase {
        return dependencies.external.resolve()
    }
}

private extension OneFavouritesListViewModel {
    func loadFavoritesListInfo() {
        Publishers.Zip(getFavoritesUseCase.fetchContacts(),
                       getSepaInfoUseCase.fetchSepaList())
            .receive(on: Schedulers.main)
            .sink(receiveCompletion: handleFavouritesResult,
                  receiveValue: showFavourites)
            .store(in: &anySubscriptions)
    }

    func showFavourites(_ payees: [PayeeRepresentable], sepaList: SepaInfoListRepresentable?) {
        guard !payees.isEmpty else {
            self.stateSubject.send(.empty(.noContacts))
            return
        }
        self.stateSubject.send(.contactsLoaded(payees, sepaList))
    }
    
    func handleFavouritesResult(_ result: Subscribers.Completion<Error>) {
        switch result {
        case .failure:
            self.stateSubject.send(.empty(.noContacts))
        case .finished:
            break
        }
    }
}
