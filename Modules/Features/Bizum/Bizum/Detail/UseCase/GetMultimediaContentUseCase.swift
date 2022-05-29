import Foundation
import CoreFoundationLib
import SANLibraryV3

struct GetMultimediaContentInputUseCase {
    let checkPayment: BizumCheckPaymentEntity
    let operationId: String
}

struct GetMultimediaContentOutput {
    let multimediaData: BizumMultimediaData
}

final class GetMultimediaContentUseCase: UseCase<GetMultimediaContentInputUseCase, GetMultimediaContentOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    override func executeUseCase(requestValues: GetMultimediaContentInputUseCase) throws -> UseCaseResponse<GetMultimediaContentOutput, StringErrorOutput> {
        let input = generateInput(requestValues)
        let response = try self.provider.getBSANBizumManager().getMultimediaContent(input)
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        guard let multimedia = generateOutput(BizumGetMultimediaContentEntity(dto)) else {
            return .error(StringErrorOutput(""))
        }
        let output = GetMultimediaContentOutput(multimediaData: multimedia)
        return .ok(output)
    }
}

private extension GetMultimediaContentUseCase {
    func generateInput(_ input: GetMultimediaContentInputUseCase) -> BizumMultimediaContentInputParams {
        return BizumMultimediaContentInputParams(checkPayment: input.checkPayment.dto,
                                                 operationId: input.operationId)
    }

    func generateOutput(_ entity: BizumGetMultimediaContentEntity) -> BizumMultimediaData? {
        guard let additionalContent = entity.additionalContentList.first else { return nil }
        let helper = HelperMultimedia()
        let image = helper.decodeImage(text: additionalContent.image ?? "")
        let text = helper.decodeText(additionalContent.text)
        return BizumMultimediaData(image: image, note: text)
    }
}
