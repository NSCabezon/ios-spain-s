protocol MifidAppConfigChecker {
    var appConfigRepository: AppConfigRepository { get }
    
    func checkMifidAppConfigEnabled(key: String) -> Bool?
}

extension MifidAppConfigChecker {
    func checkMifidAppConfigEnabled(key: String) -> Bool? {
        return appConfigRepository.getAppConfigNode(nodeName: key)
    }
}
