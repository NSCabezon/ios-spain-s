import Alamofire

public class RetailServerTrustPoliceManager: ServerTrustPolicyManager {
    init() {
        super.init(policies: [:])
    }
}

public class ProductionServerTrustPoliceManager: RetailServerTrustPoliceManager {
    public override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        guard !hostsToAvoidServerTrustPolicy.contains(host) else {
            return .disableEvaluation
        }
        return .pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(),
                              validateCertificateChain: true,
                              validateHost: true)
    }
    
    private var hostsToAvoidServerTrustPolicy: [String] {
        return [
            "adn.bsan.mobi",
            "scaweb.bsan.mobi",
            "back-weu.azurewebsites.net"
        ]
    }
}

public class DevelopmentServerTrustPoliceManager: RetailServerTrustPoliceManager {
    public override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        return .disableEvaluation
    }
}

extension ServerTrustPolicyManager {
    public static var production: ServerTrustPolicyManager {
        return ProductionServerTrustPoliceManager()
    }
    
    public static var development: ServerTrustPolicyManager {
        return DevelopmentServerTrustPoliceManager()
    }
}
