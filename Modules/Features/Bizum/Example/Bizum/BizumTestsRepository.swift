import CoreFoundationLib

class AppConfigRepositoryFake: AppConfigRepositoryProtocol {
    func getAppConfigListNode<T>(_ nodeName: String, object: T.Type, options: AppConfigDecodeOptions) -> [T]? where T: Decodable {
        return nil
    }
    
    func getInt(_ nodeName: String) -> Int? {
        return nil
    }
    
    func getAppConfigListNode(_ nodeName: String) -> [String]? {
        return ["mulMovUrls"]
    }
    
    func getBool(_ nodeName: String) -> Bool? {
        switch nodeName {
        case "enableBizumNative",
             "enableSendMoneyBizumNative",
             "enableRequestMoneyBizumNative",
             "enableReturnMoneyReceivedBizumNative",
             "enableAcceptMoneyRequestBizumNative",
             "enableSplitExpenseBizum",
             "enableBizumRedsysDocumentID",
             "enableBizumDonations",
             "enableBizumBiometricSendmoney":
            return true
        default:
            return nil
        }
    }
    
    func getDecimal(_ nodeName: String) -> Decimal? { return nil }
    func getString(_ nodeName: String) -> String? { return nil }
}

//import Repository
//
public final class BizumAppConfigRepositoryMock {
    private var configuration: [String: Any] = [:]

    public init() {
    }

    public func setConfiguration(_ configuration: [String: Any]) {
        self.configuration = configuration
    }
}

extension BizumAppConfigRepositoryMock: AppConfigRepositoryProtocol {
    public func getAppConfigListNode<T>(_ nodeName: String, object: T.Type, options: AppConfigDecodeOptions) -> [T]? where T : Decodable {
        guard var string: String = self.configuration[nodeName] as? String else { return nil }
        switch options {
        case .json5Allowed:
            string = string.replace("'", "\"")
        default: break
        }
        guard let data = string.data(using: .utf8),
            let object = try? JSONDecoder().decode([T].self, from: data) else { return nil }
        return object
    }

    public func getBool(_ nodeName: String) -> Bool? {
        return self.configuration[nodeName] as? Bool
    }

    public func getDecimal(_ nodeName: String) -> Decimal? {
        return self.configuration[nodeName] as? Decimal
    }

    public func getInt(_ nodeName: String) -> Int? {
        return self.configuration[nodeName] as? Int
    }

    public func getString(_ nodeName: String) -> String? {
        return self.configuration[nodeName] as? String
    }

    public func getAppConfigListNode(_ nodeName: String) -> [String]? {
        return self.configuration[nodeName] as? [String]
    }


}
