import Foundation

public class OperationResponse<Result, Err> {

    private var useCaseResponse: UseCaseResponse<Result, Err>?
    private var exception: Error?

    public init(_ useCaseResponse: UseCaseResponse<Result, Err>) {
        self.useCaseResponse = useCaseResponse
    }

    public init(_ exception: Error) {
        self.exception = exception
    }

    public func isOkResult() throws -> Bool {
        if let exception = exception {
            throw exception
        }
        return useCaseResponse!.isOkResult
    }

    public func getOkResult() throws -> Result {
        return try useCaseResponse!.getOkResult()
    }

    public func getErrorResult() throws -> Err {
        return try useCaseResponse!.getErrorResult()
    }
}

