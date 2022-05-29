import SANLegacyLibrary

public class DemoInterpreter: DemoInterpreterProtocol {

    static let demoUserPB = "12345678Z"
    static let demoUserNoPB = "12345679Z"

    let demoProvider: BSANDemoProviderProtocol
    let defaultDemoUser: String

    public init(demoProvider: BSANDemoProviderProtocol, defaultDemoUser: String) {
        self.demoProvider = demoProvider
        self.defaultDemoUser = defaultDemoUser
    }

    public func isDemoUser(userName: String) -> Bool {
        switch userName.uppercased() {
        case DemoInterpreter.demoUserNoPB:
            return true
        case DemoInterpreter.demoUserPB:
            return true
        default:
            return false
        }
    }
    
    public func getDefaultDemoUser() -> String {
        return defaultDemoUser
    }

    public func getDemoUser() -> String? {
        if let demoMode = demoProvider.getDemoMode() {
            return demoMode.demoUser
        }

        return defaultDemoUser
    }

    public func getGlobalPositionRequestAnswer() -> Int {
        let demoUser = getDemoUser()
        switch demoUser {
        case DemoInterpreter.demoUserPB:
            return 1
        default:
            return 0
        }
    }

    public func getAnswerNumber(serviceName: String) -> Int {
        var answerNumber = 0
        switch serviceName {
        case InsuranceDataSourceImpl.INSURANCE_DATA_SERVICE_NAME:
            answerNumber = 2
        case GlobalPositionRequest.SERVICE_NAME:
            answerNumber = getGlobalPositionRequestAnswer()
        case GlobalPositionRequest.SERVICE_NAME_PB:
            answerNumber = 2
        case GetSociusDetailAccountsAllRequest.SERVICE_NAME:
            answerNumber = 7
        case GetStockCCVRequest.serviceName:
            answerNumber = 0
        case GetCardTransactionsRequest.serviceName:
            answerNumber = 1
        case AccountTransactionsRequest.serviceNameDates:
            answerNumber = 1
        case GetMifidClausesRequest.SERVICE_NAME:
            answerNumber = 0
        case CheckTransferStatusRequest.serviceName:
            answerNumber = 0
        case CheckEntityAdheredRequest.serviceName:
            answerNumber = 0
        case AccountEasyPayRequest.serviceName:
            answerNumber = 1
        case GetClausesPensionMifidRequest.SERVICE_NAME:
            answerNumber = 2
        case ConfirmScaRequest.serviceName:
            answerNumber = 0
        case FinancialAgregatorProtocolDataSource.SERVICE_NAME:
            answerNumber = 0
        case BranchLocatorDataSourceImpl.GLOBILE_SERVICE_NAME:
            answerNumber = 0
        case BranchLocatorDataSourceImpl.SAN_SERVICE_NAME:
            answerNumber = 0
        case GetTransactionDetailEasyPayRequest.serviceName:
            answerNumber = Int.random(in: 0...2)
        case ValidateGenericTransferOTPRequest.serviceName:
            answerNumber = 3
        default:
            break
        }
        BSANLogger.i(logTag, "[\(serviceName)] getAnswerNumber result \(answerNumber)")
        return answerNumber
    }

    public var logTag: String {
        return String(describing: type(of: self))
    }
}
