import Alamofire

class RetailServerTrustPoliceManager: ServerTrustPolicyManager {
    init() {
        super.init(policies: [:])
    }
}

class ProductionServerTrustPoliceManager: RetailServerTrustPoliceManager {
    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        guard host != "adn.bsan.mobi" else {
            return .disableEvaluation
        }
        return .pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(),
                              validateCertificateChain: true,
                              validateHost: true)
    }
}

class DevelopmentServerTrustPoliceManager: RetailServerTrustPoliceManager {
    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        return .disableEvaluation
    }
}

extension ServerTrustPolicyManager {
    static var production: ServerTrustPolicyManager {
        return ProductionServerTrustPoliceManager()
    }
    
    static var development: ServerTrustPolicyManager {
        return DevelopmentServerTrustPoliceManager()
    }
}
