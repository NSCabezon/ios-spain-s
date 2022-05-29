import OpenCombine
import CoreDomain

public protocol GetAllTransfersReactiveUseCase {
    func fetchTransfers() -> AnyPublisher<GetAllTransfersReactiveUseCaseOutput, Never>
}

public struct GetAllTransfersReactiveUseCaseOutput {
    public let emitted: [TransferRepresentable]
    public let received: [TransferRepresentable]
    
    public init(emitted: [TransferRepresentable],
                received: [TransferRepresentable]) {
        self.emitted = emitted
        self.received = received
    }
}
