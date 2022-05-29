//

import Foundation

public class BranchLocatorDataSourceImpl: BranchLocatorDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let branchLocatorGlobileServicePath = "/branch-locator"
    private let branchLocatorSANServicePath = "/api/v1/cajeros"
    public static let SAN_SERVICE_NAME = "cajeros"
    public static let GLOBILE_SERVICE_NAME = "branch-locator"

    private let branchLocatorDefaultView = "/find/defaultView"
    private let headers = ["X-Santander-Channel" : "RML"]

    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func getNearATMs(_ input: BranchLocatorATMParameters) throws -> BSANResponse<[BranchLocatorATMDTO]> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()

        guard let source = bsanEnvironment.branchLocatorGlobile, let url = URL(string: source) else {
            return BSANErrorResponse(nil)
        }
        let baseUrl = url
        .appendingPathComponent(branchLocatorGlobileServicePath)
        .appendingPathComponent(branchLocatorDefaultView)

        var params: [String : String] = ["country": input.country,
                                         "customer": input.customer ? "true" : "false",
                                         "filterSubtype": "SANTANDER_ATM"]
        params["config"] = "{\"coords\":[\(input.lat), \(input.lon)]}"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        return try self.executeRestCall(serviceName: BranchLocatorDataSourceImpl.GLOBILE_SERVICE_NAME,
                                        serviceUrl: baseUrl.absoluteString,
                                        queryParam: params,
                                        body: nil,
                                        requestType: .get,
                                        responseEncoding: .utf8)
    }
    
    func getEnrichedATM(_ input: BranchLocatorEnrichedATMParameters) throws -> BSANResponse<[BranchLocatorATMEnrichedDTO]> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let sourceUrl = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = sourceUrl + self.branchLocatorSANServicePath
        let bodyParams = Body(bodyParam: input.branches)
        return try self.executeRestCall(serviceName: BranchLocatorDataSourceImpl.SAN_SERVICE_NAME,
                                        serviceUrl: url,
                                        queryParam: nil,
                                        body: bodyParams,
                                        requestType: .post,
                                        headers: headers,
                                        responseEncoding: .utf8)
    }
}

