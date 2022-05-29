import CoreFoundationLib
import SANLegacyLibrary

class UpdateTokenPushUseCase: UseCase<UpdateTokenPushUseCaseInput, UpdateTokenPushUseCaseOkOutput, GenericUseCaseErrorOutput> {
    
    let provider: BSANManagersProvider
    private let compilation: CompilationProtocol
    
    init(bsanManagerProvider: BSANManagersProvider, dependenciesResolver: DependenciesResolver) {
        self.provider = bsanManagerProvider
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override public func executeUseCase(requestValues: UpdateTokenPushUseCaseInput) throws -> UseCaseResponse<UpdateTokenPushUseCaseOkOutput, GenericUseCaseErrorOutput> {
        
        guard requestValues.oldTokenPush != requestValues.newTokenPush else {
            return .ok(UpdateTokenPushUseCaseOkOutput(tokenState: .match))
        }
        let oldToken = requestValues.oldTokenPush?.map { String(format: "%02.2hhx", $0) }.joined() ?? ""
        let newToken = requestValues.newTokenPush.map { String(format: "%02.2hhx", $0) }.joined()
        do {
            let response = try provider.getBsanOTPPushManager().updateTokenPush(currentToken: oldToken, newToken: newToken)
            
            guard response.isSuccess() else {
                return .error(GenericUseCaseErrorOutput(try response.getErrorMessage(), try response.getErrorCode()))
            }
            let query = KeychainQuery(compilation: compilation,
                                          accountPath: \.keychain.account.tokenPush,
                                          data: requestValues.newTokenPush as NSCoding)
            do {
                try KeychainWrapper().save(query: query)
                return UseCaseResponse.ok(UpdateTokenPushUseCaseOkOutput(tokenState: .update))
            } catch {
                return .error(GenericUseCaseErrorOutput(nil, nil))
            }
        } catch {
            return .error(GenericUseCaseErrorOutput(nil, nil))
        }        
    }
}

struct UpdateTokenPushUseCaseInput {
    let oldTokenPush: Data?
    let newTokenPush: Data
}

struct UpdateTokenPushUseCaseOkOutput {
    let tokenState: PushTokenSavedState
}

enum PushTokenSavedState {
    case update, match
}
