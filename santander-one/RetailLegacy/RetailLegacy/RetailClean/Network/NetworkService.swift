public protocol NetworkService {
    func executeCall<Handler, Response>(request: NetworkRequest<Handler, Response>) throws -> Response
}
