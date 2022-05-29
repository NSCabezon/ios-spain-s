import CoreFoundationLib

public struct DeleteStandingOrderUseCaseUseCaseInput {
    public let order: StandingOrderEntity
}

public typealias DeleteStandingOrderUseCaseType = UseCase<DeleteStandingOrderUseCaseUseCaseInput, Void, StringErrorOutput>

public protocol DeleteStandingOrderUseCaseProtocol: DeleteStandingOrderUseCaseType {}
