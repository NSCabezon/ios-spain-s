import CoreFoundationLib
import Foundation
import SANLegacyLibrary

protocol MifidAdviceProtocol {
    var title: String? { get }
    var message: String? { get }
    var resultCode: String? { get }
    var evaluationResultCode: String? { get }
}

extension MifidAdviceDTO: MifidAdviceProtocol {
    var title: String? {
        return adviceTitle
    }
    var message: String? {
        return adviceMessage
    }
    var resultCode: String? {
        return adviceResultCode
    }
    var evaluationResultCode: String? {
        return mifidEvaluationResultCode
    }
}

protocol MifidAdvicesResponsePrototocol {
    var advice: MifidAdviceProtocol? { get }
}

class MifidAdvicesUseCase<Input: MifidAdvicesUseCaseInputProtocol, ResponseData: MifidAdvicesResponsePrototocol>: UseCase<Input, (state: MifidAdviceState, data: ResponseData), MifidAdvicesUseCaseErrorOutput> {
    
    struct Contants {
        let adviceWarningValues = ["01", "04", "05", "06", "07"]
        let evaluationErrorValues = ["BL", "ER", "PE"]
    }
    
    let appConfigRepository: AppConfigRepository
    let provider: BSANManagersProvider
    
    private lazy var isMifidAdvicesEnabled: Bool = {
        return checkMifidAppConfigEnabled(key: DomainConstant.enableMifidAdvices) ?? true
    }()
    
    init(appConfigRepository: AppConfigRepository, managersProvider: BSANManagersProvider) {
        self.appConfigRepository = appConfigRepository
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Input) throws -> UseCaseResponse<(state: MifidAdviceState, data: ResponseData), MifidAdvicesUseCaseErrorOutput> {

        let mifidResponse = try getMifidResponse(requestValues: requestValues)
        guard mifidResponse.isSuccess(), let data = try mifidResponse.getResponseData() else {
            let errorDescription =  try mifidResponse.getErrorMessage() ?? ""
            return UseCaseResponse.error(MifidAdvicesUseCaseErrorOutput(errorDescription))
        }
        
        var state: MifidAdviceState = .none
        if isMifidAdvicesEnabled, let message = data.advice?.message {
            let constants = Contants()
            let adviceWarningValues = constants.adviceWarningValues
            if (adviceWarningValues.first { $0 == data.advice?.resultCode }) != nil {
                
                let evaluationErrorValues = constants.evaluationErrorValues
                if (evaluationErrorValues.first { $0 == data.advice?.evaluationResultCode }) != nil {
                    state = .adviceBlocking(title: data.advice?.title, message: message)
                } else {
                    state = .adviceAndContinue(title: data.advice?.title, message: message)
                }
            }
        }
        
        return UseCaseResponse.ok((state: state, data: data))
    }
    
    func getMifidResponse(requestValues: Input) throws -> BSANResponse<ResponseData> {
        fatalError()
    }
}

extension MifidAdvicesUseCase: MifidAppConfigChecker {}

protocol MifidAdvicesUseCaseInputProtocol {
    associatedtype Data
    var data: Data { get }
}

class MifidAdvicesUseCaseErrorOutput: StringErrorOutput { }
