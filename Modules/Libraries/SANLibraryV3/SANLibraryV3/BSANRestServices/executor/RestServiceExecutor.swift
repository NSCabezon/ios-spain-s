import Foundation

public enum ContentType : String{
    case urlEncoded = "x-www-form-urlencoded"
    case json = "json"
    @available(*, deprecated, message: "Content type should not be queryString")
    case queryString = "query"
}

public protocol RestServiceExecutor {
    func executeCall (restRequest: RestRequest) throws -> Any?
}
