import CoreFoundationLib
import Foundation
import SANLegacyLibrary

protocol PredefinedSCAInternalTransferUseCaseProtocol: UseCase<Void, PredefinedSCAInternalTransferUseCaseOkOutput, StringErrorOutput> {}

final class PredefinedSCAInternalTransferUseCase: UseCase<Void, PredefinedSCAInternalTransferUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PredefinedSCAInternalTransferUseCaseOkOutput, StringErrorOutput> {
        let response = self.provider.getBsanPredefineSCAManager()
            .getInternalTransferPredefinedSCA()
        guard response.isSuccess(), let representable = try response.getResponseData() else {
            return .ok(PredefinedSCAInternalTransferUseCaseOkOutput(predefinedSCAEntiy: nil))
        }
        let predefineSCAEnity = PredefinedSCAEntity(rawValue: representable.rawValue)
        return .ok(PredefinedSCAInternalTransferUseCaseOkOutput(predefinedSCAEntiy: predefineSCAEnity))
    }
}

extension PredefinedSCAInternalTransferUseCase: PredefinedSCAInternalTransferUseCaseProtocol {}

struct PredefinedSCAInternalTransferUseCaseOkOutput {
    let predefinedSCAEntiy: PredefinedSCAEntity?
}
