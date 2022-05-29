import Foundation
import CoreFoundationLib
import SANLibraryV3
import SANLegacyLibrary

struct SendMultimediaMultiInputUseCase {
    let emitterId: String
    let multiOperationId: String
    let receivers: [SendMultimediaMultiReceiverInput]
    let image: Data?
    let text: String?
    let operationType: BizumSendMultimediaOperationType
}

struct SendMultimediaMultiReceiverInput {
    let receiverUserId: String
    let operationId: String
}

struct SendMultimediaMultiUseCaseOutput {
    let transferInfoEntity: BizumTransferInfoEntity
}

final class SendMultimediaMultiUseCase: UseCase<SendMultimediaMultiInputUseCase, SendMultimediaMultiUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: SANLibraryV3.BSANManagersProvider

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: SANLibraryV3.BSANManagersProvider.self)
    }

    override func executeUseCase(requestValues: SendMultimediaMultiInputUseCase) throws -> UseCaseResponse<SendMultimediaMultiUseCaseOutput, StringErrorOutput> {
        let input = generateInput(requestValues)
        let response = try self.provider.getBSANBizumManager().sendImageTextMulti(input)
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        return .ok(SendMultimediaMultiUseCaseOutput(transferInfoEntity: BizumTransferInfoEntity(dto)))
    }
}

private extension SendMultimediaMultiUseCase {
    func generateInput(_ requestValues: SendMultimediaMultiInputUseCase ) -> BizumSendImageTextMultiInputParams {
        let helperMultimedia = HelperMultimedia()        
        let base64Image: String? = helperMultimedia.encodeData(image: requestValues.image)
        let base64EncodedString = helperMultimedia.encodeDataStringWithEmoji(requestValues.text)
        let operationReceiverList = requestValues.receivers.map { BizumMultimediaReceiverInputParam(receiverUserId: $0.receiverUserId,
                                                                                                                                operationId: $0.operationId) }
        let imageFormat = helperMultimedia.getImageFormat(base64Image)
        return BizumSendImageTextMultiInputParams(emmiterUserId: requestValues.emitterId.trim(),
                                                  multiOperationId: requestValues.multiOperationId,
                                                  operationReceiverList: operationReceiverList,
                                                  image: base64Image,
                                                  imageFormat: imageFormat,
                                                  text: base64EncodedString,
                                                  operationType: BizumSendMultimediaOperationTypeDTO(from: requestValues.operationType))
    }
}
