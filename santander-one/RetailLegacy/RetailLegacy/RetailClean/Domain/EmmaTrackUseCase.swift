import CoreFoundationLib

public class EmmaTrackUseCase: UseCase<EmmaTrackUseCaseInput, Void, StringErrorOutput> {
    public override func executeUseCase(requestValues: EmmaTrackUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        return UseCaseResponse.ok()
    }
}

public struct EmmaTrackUseCaseInput {
    let trackToken: String
    
    public init(trackToken: String) {
        self.trackToken = trackToken
    }
}
