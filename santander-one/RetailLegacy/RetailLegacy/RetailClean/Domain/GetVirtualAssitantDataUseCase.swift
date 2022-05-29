import CoreFoundationLib

class GetVirtualAssitantDataUseCase: GetInbentaDataUseCase<Void, GetVirtualAssitantDataUseCaseOkOutput> {
    override var nodes: [String] {
        return [DomainConstant.appConfigVirtualAssistantUrl, DomainConstant.appConfigVirtualAssistantCloseUrl]
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetVirtualAssitantDataUseCaseOkOutput, StringErrorOutput> {
        let nodesTable = getNodes()
        let webViewTimer = appConfigRepository.getString("timerLoadingTips") ?? "0"
        guard let url = nodesTable[DomainConstant.appConfigVirtualAssistantUrl], let closeUrl = nodesTable[DomainConstant.appConfigVirtualAssistantCloseUrl] else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return UseCaseResponse.ok(GetVirtualAssitantDataUseCaseOkOutput(url: url, closeUrl: closeUrl, webViewTimer: Int(webViewTimer)))
    }
}

struct GetVirtualAssitantDataUseCaseOkOutput {
    let url: String
    let closeUrl: String
    let webViewTimer: Int?
}
