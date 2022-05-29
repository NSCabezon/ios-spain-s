import Foundation

public protocol SanRestServices {
    
    func executeRestCall(request: RestRequest) throws -> Any?
}
