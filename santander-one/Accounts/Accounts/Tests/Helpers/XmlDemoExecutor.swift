import SANLibraryV3

class XmlDemoExecutor: SoapServiceExecutor {
    
    private var stubs: [XmlStubResponse] = []
    private var exceptions: [StubException] = []
    
    func addStub(_ stub: XmlStubResponse) {
        defer { stubs.append(stub) }
        guard let index = stubs.firstIndex(where: { stub.serviceName == $0.serviceName }) else { return }
        stubs.remove(at: index)
    }
    
    func addStubs(_ stubs: [XmlStubResponse]) {
        stubs.forEach(addStub)
    }
    
    func addException(_ exception: StubException) {
        exceptions.append(exception)
    }
    
    func removeAll() {
        exceptions.removeAll()
        stubs.removeAll()
    }
    
    func executeCall<Response, Params, Handler, Parser, Request>(request: Request) throws -> String where Response : BSANSoapResponse, Handler : BSANHandler, Parser : BSANParser<Response, Handler>, Request : BSANSoapRequest<Params, Handler, Response, Parser> {
        if let exception = exceptions.first(where: { request.serviceName == $0.serviceName }) {
            throw exception.exception
        }
        return stubs.first(where: { request.serviceName == $0.serviceName })?.response() ?? ""
    }
}
