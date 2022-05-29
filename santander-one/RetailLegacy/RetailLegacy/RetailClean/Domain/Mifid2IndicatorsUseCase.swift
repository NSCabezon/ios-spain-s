import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class Mifid2IndicatorsUseCase<Input: Mifid2IndicatorsUseCaseInputProtocol>: UseCase<Input, Mifid2IndicatorsUseCaseOkOutput, Mifid2IndicatorsUseCaseErrorOutput> {
    
    let appConfigRepository: AppConfigRepository
    let provider: BSANManagersProvider
    
    private lazy var isMifid2Enabled: Bool = {
        return checkMifidAppConfigEnabled(key: DomainConstant.enableMifid2) ?? true
    }()
    
    init(appConfigRepository: AppConfigRepository, managersProvider: BSANManagersProvider) {
        self.appConfigRepository = appConfigRepository
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Input) throws -> UseCaseResponse<Mifid2IndicatorsUseCaseOkOutput, Mifid2IndicatorsUseCaseErrorOutput> {
        
        var mifidIndicators: MifidIndicators = .nothingToDo
        
        if isMifid2Enabled, let possibleResponse = try getMifidResponse(requestValues: requestValues) {
            guard possibleResponse.isSuccess(), let data = try possibleResponse.getResponseData() else {
                let errorDescription =  try possibleResponse.getErrorMessage() ?? ""
                return UseCaseResponse.error(Mifid2IndicatorsUseCaseErrorOutput(errorDescription))
            }
            
            if let evaluatedList = data.evaluatedList {
                let userClasified = evaluatedList.first?.indClasFirma ?? false
                let validTest = (evaluatedList.first {
                    $0.testList.first {
                        $0.indVigencia == true
                        } != nil
                }) != nil
                
                if !userClasified && !validTest {
                    mifidIndicators = .invalid(error: .noTestAndNotClasified)
                } else if !userClasified {
                    mifidIndicators = .invalid(error: .notClasified)
                } else if !validTest {
                    mifidIndicators = .invalid(error: .noTest)
                }
            }
        }
        
        return UseCaseResponse.ok(Mifid2IndicatorsUseCaseOkOutput(mifidIndicators: mifidIndicators, mifid2Errors: getErrorMessages()))
    }
    
    func getMifidResponse(requestValues: Input) throws -> BSANResponse<MifidIndicatorDTO>? {
        fatalError()
    }
    
    private func getErrorMessages() -> [String: String] {
        var mifid2Errors: [String: String] = [:]
        let keys = [DomainConstant.mifid2NoTestMessage, DomainConstant.mifid2NoClasificationMessage, DomainConstant.mifid2NoTestNoClassificationMessage]
        keys.forEach {
            if let errorKey: String = appConfigRepository.getAppConfigNode(nodeName: $0) {
                mifid2Errors[$0] = errorKey
            }
        }
        return mifid2Errors
    }
}

extension Mifid2IndicatorsUseCase: MifidAppConfigChecker {}

protocol Mifid2IndicatorsUseCaseInputProtocol {
    associatedtype P
    var product: P { get }
    var mifidOperative: MifidOperative { get }
}

struct Mifid2IndicatorsUseCaseOkOutput {
    let mifidIndicators: MifidIndicators
    let mifid2Errors: [String: String]
}

class Mifid2IndicatorsUseCaseErrorOutput: StringErrorOutput { }
