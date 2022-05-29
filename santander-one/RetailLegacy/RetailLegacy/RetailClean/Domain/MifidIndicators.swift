enum MifidIndicators {
    case nothingToDo
    case invalid(error: MifidIndicatorsError)
}

enum MifidIndicatorsError {
    case noTest
    case notClasified
    case noTestAndNotClasified
    
    var appConfigKey: String {
        switch self {
        case .noTest:
            return DomainConstant.mifid2NoTestMessage
        case .notClasified:
            return DomainConstant.mifid2NoClasificationMessage
        case .noTestAndNotClasified:
            return DomainConstant.mifid2NoTestNoClassificationMessage
        }
    }
}
