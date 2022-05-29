import Foundation
import CoreFoundationLib
import SANLibraryV3

enum BizumSendMultimediaOperationType {
    case send
    case acceptMoneyRequest
    case refundMoney
    case requestMoney
}

extension BizumSendMultimediaOperationTypeDTO {
    
    init(from type: BizumSendMultimediaOperationType) {
        switch type {
        case .send:
            self = .send
        case .refundMoney:
            self = .refundMoney
        case .acceptMoneyRequest:
            self = .acceptMoneyRequest
        case .requestMoney:
            self = .requestMoney
        }
    }
}

struct SendMultimediaSimpleInputUseCase {
    let checkPayment: BizumCheckPaymentEntity
    let operationId: String
    let receiverUserId: String
    let image: Data?
    let text: String?
    let operationType: BizumSendMultimediaOperationType
}

struct SendMultimediaSimpleUseCaseOkOutput {
    let transferInfoEntity: BizumTransferInfoEntity
}

final class SendMultimediaSimpleUseCase: UseCase<SendMultimediaSimpleInputUseCase, SendMultimediaSimpleUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    override func executeUseCase(requestValues: SendMultimediaSimpleInputUseCase) throws -> UseCaseResponse<SendMultimediaSimpleUseCaseOkOutput, StringErrorOutput> {
        let input = generateInput(input: requestValues)
        let response = try self.provider.getBSANBizumManager().sendImageText(input)
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        return .ok(SendMultimediaSimpleUseCaseOkOutput(transferInfoEntity: BizumTransferInfoEntity(dto)))
    }
}

private extension SendMultimediaSimpleUseCase {
    func generateInput(input: SendMultimediaSimpleInputUseCase) -> BizumSendMultimediaInputParams {
        let helperMultimedia = HelperMultimedia()
        let base64Image: String? = helperMultimedia.encodeData(image: input.image)
        let base64EncodedString = helperMultimedia.encodeDataStringWithEmoji(input.text)
        let imageFormat = helperMultimedia.getImageFormat(base64Image)
        return BizumSendMultimediaInputParams(
            checkPayment: input.checkPayment.dto,
            operationId: input.operationId,
            receiverUserId: input.receiverUserId,
            image: base64Image ?? "",
            imageFormat: imageFormat,
            text: base64EncodedString,
            operationType: BizumSendMultimediaOperationTypeDTO(from: input.operationType)
        )
    }
}
