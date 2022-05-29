import CoreFoundationLib

public protocol GetSimpleGlobalPositionActionsUseCaseProtocol: UseCase<[GpOperativesViewModel], GetSimpleGlobalPositionActionsUseCaseProtocolOutput, StringErrorOutput> {}

public struct GetSimpleGlobalPositionActionsUseCaseProtocolOutput {
    let actions: [GpOperativesViewModel]
    
    public init(actions: [GpOperativesViewModel]) {
        self.actions = actions
    }
}
