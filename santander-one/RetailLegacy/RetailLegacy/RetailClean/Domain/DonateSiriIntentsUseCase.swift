import CoreFoundationLib

class DonateSiriIntentsUseCase: UseCase<Void, Void, StringErrorOutput> {
    let siriAssistant: SiriAssistant

    init(siriAssistant: SiriAssistant) {
        self.siriAssistant = siriAssistant
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        if #available(iOS 12.0, *) {
            siriAssistant.donateIntents()
        }
        return UseCaseResponse.ok()
    }
}
