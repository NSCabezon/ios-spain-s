import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class LoadUsualTransfersSuperUseCase {
    
    private let useCaseProvider: UseCaseProvider
    private let useCaseHandler: UseCaseHandler
    private var allUsualTransfers = [FavoriteType]()
    private let lockNoSepaDetail = DispatchSemaphore(value: 1)
    private var totalRequests: Int = 0
    private var operations: [Foundation.Operation]
    
    var isFinish: Bool {
        return totalRequests == 0
    }
    private var completion: (([FavoriteType]) -> Void)?
    
    init(useCaseProvider: UseCaseProvider, useCaseHandler: UseCaseHandler) {
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
        self.operations = []
    }
    
    func execute(onCompletion: @escaping ([FavoriteType]) -> Void) {
        UseCaseWrapper(with: useCaseProvider.getAllUsualTransfersOperativesUseCase(), useCaseHandler: useCaseHandler, errorHandler: nil, onSuccess: { [weak self] (result) in
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.lockNoSepaDetail.wait()

                    for favourite in result.transfers {
                        if favourite.iban?.countryCode == nil || favourite.accountType == "C" || favourite.accountType == "D" {
                            strongSelf.totalRequests += 1
                            strongSelf.getNoSepaDetailPayeeFor(favourite: favourite)
                        } else {
                            strongSelf.allUsualTransfers.append(NoSepaFavoriteAdapter(favorite: favourite))
                        }
                    }
                    strongSelf.lockNoSepaDetail.signal()

                    if strongSelf.isFinish {
                        onCompletion(strongSelf.allUsualTransfers)
                    } else {
                        strongSelf.completion = onCompletion
                    }
                }
            }, onError: { [weak self] _ in
                self?.allUsualTransfers = []
        })
    }
    
    private func getNoSepaDetailPayeeFor(favourite: Favourite) {
        let input = GetNoSepaPayeeDetailUseCaseInput(favourite: favourite)
        
        let usecase = useCaseProvider.getNoSepaPayeeDetailUseCase(input: input)
        let operation = LoadUsualTransfersOperation(self, useCase: usecase, favourite: favourite)
        operation.qualityOfService = QualityOfService.userInitiated
        operations.append(operation)
        useCaseHandler.execute(operation)
    }
    
    func successPage(favourite: Favourite, response: GetNoSepaPayeeDetailUseCaseOkOutput) {
        lockNoSepaDetail.wait()
        let destinationCountryCode: String
        if let bankCountryCode = response.payee.bankCountryCode, !bankCountryCode.isEmpty {
            destinationCountryCode = bankCountryCode
        } else {
            destinationCountryCode = response.payee.countryCode ?? ""
        }
        favourite.setCountryCode(countryCode: destinationCountryCode)
        allUsualTransfers.append(NoSepaFavoriteAdapter(favorite: favourite, noSepaPayee: response.payee))
        totalRequests -= 1
        if isFinish {
            completion?(allUsualTransfers)
        }
        lockNoSepaDetail.signal()
    }
    
    func cancel() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.lockNoSepaDetail.wait()
            for request in strongSelf.operations {
                request.cancel()
            }
            strongSelf.lockNoSepaDetail.signal()
        }
    }
}

class LoadUsualTransfersOperation: UseCaseOperationImpl<LoadUsualTransfersSuperUseCase, GetNoSepaPayeeDetailUseCaseInput, GetNoSepaPayeeDetailUseCaseOkOutput, GetNoSepaPayeeDetailUseCaseErrorOutput> {
    typealias UseCaseLoadNoSepaDetailPayee = UseCase<GetNoSepaPayeeDetailUseCaseInput, GetNoSepaPayeeDetailUseCaseOkOutput, GetNoSepaPayeeDetailUseCaseErrorOutput> & Cancelable
    weak var useCase: UseCaseLoadNoSepaDetailPayee?
    let favourite: Favourite
    
    init(_ parent: LoadUsualTransfersSuperUseCase, useCase: UseCaseLoadNoSepaDetailPayee, favourite: Favourite) {
        self.useCase = useCase
        self.favourite = favourite
        super.init(parent, useCase: useCase)
        finishQueue = .noChange
    }
    
    override func onSuccess(result: GetNoSepaPayeeDetailUseCaseOkOutput) {
        super.onSuccess(result: result)
        parent.successPage(favourite: favourite, response: result)
    }
    
    override func onError(err: GetNoSepaPayeeDetailUseCaseErrorOutput) {
        super.onError(err: err)
    }
    
    override open func cancel() {
        super.cancel()
        useCase?.cancel()
    }
}
