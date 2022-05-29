//
//  DeleteOtherBankConnectionViewModel.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 21/3/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

enum DeleteOtherBankConnectionState: State {
    case idle
    case bankSelectedToDelete(_ bankSelected: ProducListConfigurationOtherBanksRepresentable)
    case isDeleteStatus(_ status: DeleteOtherBankConnectionStatus)
}

final class DeleteOtherBankConnectionViewModel: DataBindable {
    
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: DeleteOtherBankConnectionDependenciesResolver
    private let stateSubject = CurrentValueSubject<DeleteOtherBankConnectionState, Never>(.idle)
    var state: AnyPublisher<DeleteOtherBankConnectionState, Never>
    @BindingOptional fileprivate var bankSelectedToDelete: ProducListConfigurationOtherBanksRepresentable?
    @BindingOptional fileprivate var updateWithDeletedBankOutsider: UpdateCompaniesOutsider?
    private let deleteBankSubject = PassthroughSubject<String, Never>()
    
    init(dependencies: DeleteOtherBankConnectionDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        subscribeDeleteBank()
        sendBankToDeleteInfo()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}
extension DeleteOtherBankConnectionViewModel {
    func didTapDeleteOtherBankConnection(_ bankCode: String) {
        subscribeDeleteBank()
        stateSubject.send(.isDeleteStatus(.loading))
        deleteBankSubject.send(bankCode)
    }
    
    func back() {
        coordinator.back()
    }
    
    func backWithDeletedBank() {
        coordinator.back()
        updateWithDeletedBankOutsider?.send(.void)
    }
}

private extension DeleteOtherBankConnectionViewModel {
    var coordinator: DeleteOtherBankConnectionCoordinator {
        return dependencies.resolve()
    }
    
    func sendBankToDeleteInfo() {
        guard let bankSelectedInfo = bankSelectedToDelete else { return }
        stateSubject.send(.bankSelectedToDelete(bankSelectedInfo))
    }
}

// MARK: - Subscriptions
private extension DeleteOtherBankConnectionViewModel {
    var deleteOtherBankConnectionUseCase: DeleteOtherBankConnectionUseCase {
        return dependencies.resolve()
    }
    
    func subscribeDeleteBank() {
        deleteBankPublisher()
            .sink(
                receiveCompletion: { [unowned self] completion in
                    guard case .failure(let error) = completion else { return }
                    stateSubject.send(.isDeleteStatus(.notDeleted))
                },
                receiveValue: { [unowned self] _ in
                    stateSubject.send(.isDeleteStatus(.deleted))
                }
            ).store(in: &anySubscriptions)
    }
}

// MARK: - Publishers
private extension DeleteOtherBankConnectionViewModel {
    func deleteBankPublisher() -> AnyPublisher<Void, Error> {
        return deleteBankSubject
            .flatMap { [unowned self] bankCode in
                deleteOtherBankConnectionUseCase
                    .fetchFinancialDeleteBankPublisher(bankCode: bankCode)
                    .map { $0 }
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

enum DeleteOtherBankConnectionStatus {
    case loading
    case deleted
    case notDeleted
}
