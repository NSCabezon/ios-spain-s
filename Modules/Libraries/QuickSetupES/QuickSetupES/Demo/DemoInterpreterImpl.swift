import SANLibraryV3

class DemoInterpreterImpl: DemoInterpreter {
    static let demoUserPB = "12345678Z"
    static let demoUserNoPB = "12345679Z"

    let bsanDataProvider: BSANDataProvider
    let defaultDemoUser: String
    private var answers: [String: Int] = [:]

    init(bsanDataProvider: BSANDataProvider, defaultDemoUser: String) {
        self.bsanDataProvider = bsanDataProvider
        self.defaultDemoUser = defaultDemoUser
    }

    func isDemoUser(userName: String) -> Bool {
        switch userName.uppercased() {
        case DemoInterpreterImpl.demoUserNoPB:
            return true
        case DemoInterpreterImpl.demoUserPB:
            return true
        default:
            return false
        }
    }
    
    func getDefaultDemoUser() -> String {
        return defaultDemoUser
    }

    func getDemoUser() -> String? {
        if let demoMode = bsanDataProvider.getDemoMode() {
            return demoMode.demoUser
        }

        return defaultDemoUser
    }

    func getGlobalPositionRequestAnswer() -> Int {
        let demoUser = getDemoUser()
        switch demoUser {
        case DemoInterpreterImpl.demoUserPB:
            return 1
        default:
            return 0
        }
    }

    func getAnswerNumber(serviceName: String) -> Int {
        if let answerNumber: Int = self.answers[serviceName] {
            return answerNumber
        } else {
            return self.internalAnswerNumber(serviceName)
        }
    }
    
    private func internalAnswerNumber(_ serviceName: String) -> Int {
        var answerNumber = 0
        switch serviceName {
        case InsuranceDataSourceImpl.INSURANCE_DATA_SERVICE_NAME:
            answerNumber = 1
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
        case GetBotesPullOffersRequest.SERVICE_NAME:
            answerNumber = 1
        case "nTransaction":
            answerNumber = 0
        case "oneTransaction":
            answerNumber = 0
        default:
            break
        }
        return answerNumber
    }
    
    func setAnswers(_ answers: [String: Int]) {
        self.answers = answers
    }
    
    var logTag: String {
        return String(describing: type(of: self))
    }
}
