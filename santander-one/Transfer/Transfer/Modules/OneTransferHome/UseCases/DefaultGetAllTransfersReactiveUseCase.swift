//
//  DefaultGetAllTransfersReactiveUseCase.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 3/2/22.
//

import OpenCombine
import CoreDomain

public protocol DefaultGetAllTransfersReactiveUseCaseDependenciesResolver {
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> TransfersRepository
}

struct DefaultGetAllTransfersReactiveUseCase {
    private let globalPositionRepository: GlobalPositionDataRepository
    private let transfersRepository: TransfersRepository
    
    init(dependencies: DefaultGetAllTransfersReactiveUseCaseDependenciesResolver) {
        self.globalPositionRepository = dependencies.resolve()
        self.transfersRepository = dependencies.resolve()
    }
}

extension DefaultGetAllTransfersReactiveUseCase: GetAllTransfersReactiveUseCase {
    func fetchTransfers() -> AnyPublisher<GetAllTransfersReactiveUseCaseOutput, Never> {
        return globalPositionRepository.getMergedGlobalPosition()
            .flatMap { (globalPosition: GlobalPositionAndUserPrefMergedRepresentable) -> AnyPublisher<GetAllTransfersReactiveUseCaseOutput, Never> in
                let filteredAccounts = globalPosition.accounts.filter { $0.isVisible }.map { $0.product }
                return loadAllTransfers(accounts: filteredAccounts)
                    .map(getDictionary)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetAllTransfersReactiveUseCase {
    func loadAllTransfers(accounts: [AccountRepresentable]) -> AnyPublisher<[TransferRepresentable], Never> {
        return transfersRepository.getAllTransfersReactive(accounts: accounts)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func getDictionary(_ tranferList: [TransferRepresentable]) -> GetAllTransfersReactiveUseCaseOutput {
        var emittedList: [TransferRepresentable] = []
        var receivedList: [TransferRepresentable] = []
        tranferList.forEach { transfer in
            if transfer.typeOfTransfer == .emitted {
                emittedList.append(transfer)
            } else {
                receivedList.append(transfer)
            }
        }
        return GetAllTransfersReactiveUseCaseOutput(emitted: emittedList, received: receivedList)
    }
}
