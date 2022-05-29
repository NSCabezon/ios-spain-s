import Foundation
import Alamofire

class CustomServerTrustPoliceManager: ServerTrustPolicyManager {
	override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
		return .disableEvaluation
	}
	
	public init() {
		super.init(policies: [:])
	}
}
