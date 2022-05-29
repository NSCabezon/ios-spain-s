import Foundation

open class UseCase<Request, Result, Err> where Err: StringErrorOutput {

    public var logTag: String {
        return String(describing: type(of: self))
    }
    
    private var mRequestValues: Request!

    func getTag() -> String {
        return String(describing: type(of: self))
    }

    public init(){}
    
    public func setRequestValues (requestValues: Request) -> UseCase<Request, Result, Err> {
        self.mRequestValues = requestValues
        return self
    }

    public func run() throws -> UseCaseResponse<Result, Err> {
        if Request.self == Void.self {
            return try executeUseCase(requestValues: () as! Request)
        }
        return try executeUseCase(requestValues: mRequestValues)
    }

    open func executeUseCase(requestValues: Request) throws -> UseCaseResponse<Result, Err> {
        fatalError()
    }
 
}
