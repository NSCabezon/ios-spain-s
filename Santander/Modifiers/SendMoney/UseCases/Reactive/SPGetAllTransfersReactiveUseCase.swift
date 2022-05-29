import CoreFoundationLib
import SANLegacyLibrary
import SANSpainLibrary
import OpenCombine
import CoreDomain
import Transfer

protocol SPGetAllTransfersReactiveUseCaseDependenciesResolver {
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> SpainTransfersRepository
    func resolve() -> SpainGlobalPositionRepository
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> GetAllTransfersUseCaseModifierProtocol?
}

struct SPGetAllTransfersReactiveUseCase {
    private let getAllTransfersUseCaseModifier: GetAllTransfersUseCaseModifierProtocol?
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let transfersRepository: SpainTransfersRepository
    private let globalPositionRepository: SpainGlobalPositionRepository
    private let globalPositionDataRepository: GlobalPositionDataRepository
    
    init(dependencies: SPGetAllTransfersReactiveUseCaseDependenciesResolver) {
        self.transfersRepository = dependencies.resolve()
        self.appConfigRepository = dependencies.resolve()
        self.globalPositionRepository = dependencies.resolve()
        self.globalPositionDataRepository = dependencies.resolve()
        self.getAllTransfersUseCaseModifier = dependencies.resolve()
    }
}

extension SPGetAllTransfersReactiveUseCase: GetAllTransfersReactiveUseCase {
    func fetchTransfers() -> AnyPublisher<GetAllTransfersReactiveUseCaseOutput, Never> {
        return loadGlobalPositionV2()
            .flatMap { _ in
                return Publishers.Zip(
                    globalPositionDataRepository.getMergedGlobalPosition(),
                    loadAppConfigValues()
                )
            }
            .flatMap(generateTransfersPublishers)
            .eraseToAnyPublisher()
    }
}

private extension SPGetAllTransfersReactiveUseCase {
    func loadGlobalPositionV2() -> AnyPublisher<Void, Never> {
        return globalPositionDataRepository.getGlobalPosition()
            .flatMap { globalPosition in
                return globalPositionRepository.loadGlobalPositionV2(onlyVisibleProducts: true, isPB: globalPosition.isPb ?? false)
            }
            .map { _ in () }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
    
    func loadAppConfigValues() -> AnyPublisher<(Int, Int), Never> {
        return appConfigRepository.values(for: [
            TransferConstant.appConfigEmittedTransfersMaxPagination: 1,
            TransferConstant.appConfigEmittedTransfersSearchMonths: 1
        ])
            .map { output -> (Int, Int) in
                return (
                    output[TransferConstant.appConfigEmittedTransfersMaxPagination] ?? 1,
                    output[TransferConstant.appConfigEmittedTransfersSearchMonths] ?? 1
                )
            }
            .eraseToAnyPublisher()
    }
}

private extension SPGetAllTransfersReactiveUseCase {
    func generateTransfersPublishers(globalPosition: GlobalPositionAndUserPrefMergedRepresentable, appConfigValues: (Int, Int)) -> AnyPublisher<GetAllTransfersReactiveUseCaseOutput, Never> {
        let filteredAccounts = globalPosition.accounts.filter { $0.isVisible }.map { $0.product }
        let maxPages = appConfigValues.0
        let monthsBackToSearch = appConfigValues.1
        
        return Publishers.Zip(
            mergeTransfers(from: filteredAccounts) { account in
                getEmittedTransfers(account: account, maxPages: maxPages, maxMonths: monthsBackToSearch)
            },
            mergeTransfers(from: filteredAccounts) { account in
                getReceivedTransfers(account: account, maxPages: maxPages, maxMonths: monthsBackToSearch)
            }
        )
            .map { notFiltered -> ([TransferRepresentable], [TransferRepresentable]) in
                guard let getAllTransfersUseCaseModifier = getAllTransfersUseCaseModifier else { return notFiltered }
                return (
                    getAllTransfersUseCaseModifier.filterBizumTransfers(notFiltered.0),
                    getAllTransfersUseCaseModifier.filterBizumTransfers(notFiltered.1)
                )
            }
            .map { output in
                return GetAllTransfersReactiveUseCaseOutput(emitted: output.0, received: output.1)
            }
            .eraseToAnyPublisher()
    }
    
    func mergeTransfers(
        from accounts: [AccountRepresentable],
        doing loadAction: (AccountRepresentable) -> AnyPublisher<[TransferRepresentable], Never>
    ) -> AnyPublisher<[TransferRepresentable], Never> {
        return Publishers.MergeMany(accounts.map(loadAction))
            .reduce([TransferRepresentable]()) { $0 + $1 }
            .eraseToAnyPublisher()
    }
    
    func createPaginatingPublisher(
        maxPages: Int,
        loadingAction: @escaping (PaginationRepresentable?) -> AnyPublisher<TransferListResponse, Error>
    ) -> AnyPublisher<[TransferRepresentable], Never> {
        let paginationPublisher = CurrentValueSubject<(pagination: PaginationRepresentable?, page: Int), Never>((nil, 0))
        return paginationPublisher
            .flatMap { nextPage in
                return loadingAction(nextPage.pagination)
                    .replaceError(with: TransferListResponse(transactions: [], pagination: nil))
                    .handleEvents(receiveOutput: { (response: TransferListResponse) in
                        if nextPage.page < maxPages, let pagination = response.pagination {
                            paginationPublisher.send((pagination, nextPage.page))
                        } else {
                            paginationPublisher.send(completion: .finished)
                        }
                    })
            }
            .collect()
            .map { (options: [TransferListResponse]) -> [TransferRepresentable] in
                return options.reduce([TransferRepresentable]()) { $0 + $1.transactions }
            }
            .eraseToAnyPublisher()
    }
}

private extension SPGetAllTransfersReactiveUseCase {
    func getEmittedTransfers(account: AccountRepresentable, maxPages: Int, maxMonths: Int) -> AnyPublisher<[TransferRepresentable], Never> {
        return createPaginatingPublisher(maxPages: maxPages) { pagination in
            loadEmittedTransfers(for: account, withPagination: pagination, maxMonths: maxMonths)
        }
            .map { output -> [TransferRepresentable] in
                var transfers = output
                for (index, transfer) in transfers.enumerated() {
                    if var transfer = transfer as? TransferEmittedDTO {
                        transfer.ibanString = account.getIBANString
                        transfers[index] = transfer
                    }
                }
                return transfers
            }
            .eraseToAnyPublisher()
    }
    
    private func loadEmittedTransfers(for account: AccountRepresentable, withPagination pagination: PaginationRepresentable?, maxMonths: Int) -> AnyPublisher<TransferListResponse, Error> {
        return transfersRepository.loadEmittedTransfers(
            account: account,
            amountFrom: nil,
            amountTo: nil,
            dateFilter: DateFilter.createSubtractingMonths(months: maxMonths),
            pagination: pagination
        )
    }
}

private extension SPGetAllTransfersReactiveUseCase {
    func getReceivedTransfers(account: AccountRepresentable, maxPages: Int, maxMonths: Int) -> AnyPublisher<[TransferRepresentable], Never> {
        return createPaginatingPublisher(maxPages: maxPages) { pagination in
            loadReceivedTransfers(for: account, withPagination: pagination, maxMonths: maxMonths)
        }
            .map { output -> [TransferRepresentable] in
                var transfers = output
                for (index, transfer) in transfers.enumerated() {
                    if var transfer = transfer as? AccountTransactionDTO {
                        transfer.senderAccountNumber = account.getIBANString
                        transfers[index] = transfer
                    }
                }
                return transfers
            }
            .eraseToAnyPublisher()
    }
    
    private func loadReceivedTransfers(for account: AccountRepresentable, withPagination pagination: PaginationRepresentable?, maxMonths: Int) -> AnyPublisher<TransferListResponse, Error> {
        return transfersRepository.getAccountTransactions(
            forAccount: account,
            pagination: pagination,
            filter: AccountTransferFilterInput(
                endAmount: nil,
                startAmount: nil,
                transferType: TransferType.transfersReceived,
                movementType: MovementType.all,
                dateFilter: DateFilter.createSubtractingMonths(months: maxMonths)
            )
        )
    }
}
