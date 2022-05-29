import Foundation

open class UseCaseResponse<Result, Err> {

    public static func ok(_ okResult: Result) -> UseCaseResponse<Result, Err> {
        return UseCaseResponse(okResult: okResult)
    }

    public static func ok() -> UseCaseResponse<Result, Err> {
        return UseCaseResponse()
    }

    public static func error(_ errorResult: Err) -> UseCaseResponse<Result, Err> {
        return UseCaseResponse(errorResult: errorResult)
    }

    private let okResult: Result?
    private let errorResult: Err?

    public var isOkResult: Bool {
        return errorResult == nil
    }

    public func getOkResult() throws -> Result {
        if isOkResult {
            if Result.self == Void.self {
                return () as! Result
            }
            return okResult!
        } else {
            throw IllegalStateException("cannot call to getOkResult if !isOkResult!")
        }
    }

    public func getErrorResult() throws -> Err {

        if let _ = okResult {
            throw IllegalStateException("cannot call to getErrorResult if isOkResult!")
        }

        if Err.self == Void.self {
            return () as! Err
        } else {
            return errorResult!
        }
    }

    private init() {
        self.okResult = nil
        self.errorResult = nil
    }

    private init(okResult: Result) {
        self.okResult = okResult
        self.errorResult = nil
    }

    private init(errorResult: Err) {
        self.okResult = nil
        self.errorResult = errorResult
    }
}
