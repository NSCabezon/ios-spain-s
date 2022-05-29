import Foundation
import Fuzi

public class CheckOnePlanParser: BSANParser<CheckOnePlanResponse, CheckOnePlanHandler> {
    override func setResponseData() {
        response.dto = handler.dto
        response.statusCode = handler.statusCode
    }
}

public class CheckOnePlanHandler: BSANHandler {
    fileprivate var dto: CustomerContractListDTO?
    fileprivate var statusCode: Int?
    
    override func parseResult(result: XMLElement) throws {
        guard
            let statusString = result.firstChild(tag: "status")?.stringValue.trim(),
            let status = Int(statusString)
            else { return }
        switch StatusCode(rawValue: status) {
        case .success?:
            parseJson(result)
        default:
            break
        }
        statusCode = status
    }
    
    private func parseJson(_ result: XMLElement) {
        guard
            let jsonNode = result.firstChild(tag: "json"),
            let data = jsonNode.stringValue.data(using: .utf8)
            else { return }
        dto = try? JSONDecoder().decode(CustomerContractListDTO.self, from: data)
    }
    
    private enum StatusCode: Int {
        case success = 200
        case noContent = 204
        case internalServerError = 500
        case unathourized = 401
    }
}
