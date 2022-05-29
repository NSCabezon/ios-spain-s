import CoreFoundationLib

class GetChatInbentaDataUseCase: GetInbentaDataUseCase<Void, GetChatInbentaDataUseCaseOkOutput> {
    override var nodes: [String] {
        return [DomainConstant.appConfigInbentaChatUrl, DomainConstant.appConfigInbentaChatCloseUrl]
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetChatInbentaDataUseCaseOkOutput, StringErrorOutput> {
        let nodesTable = getNodes()
        guard let url = nodesTable[DomainConstant.appConfigInbentaChatUrl], let closeUrl = nodesTable[DomainConstant.appConfigInbentaChatCloseUrl] else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let parameters = try getParameters()
        let webViewTimer = appConfigRepository.getString("timerLoadingTips") ?? "0"
        return UseCaseResponse.ok(GetChatInbentaDataUseCaseOkOutput(url: url, closeUrl: closeUrl, parameters: parameters, webViewTimer: Int(webViewTimer)))
    }
}

struct GetChatInbentaDataUseCaseOkOutput {
    let url: String
    let closeUrl: String
    let parameters: [String: String]
    let webViewTimer: Int?
}
