import CoreFoundationLib
import SANLegacyLibrary
import ESCommons

class UpdateTokenPushUseCase: UseCase<UpdateTokenPushUseCaseInput, UpdateTokenPushUseCaseOkOutput, GenericUseCaseErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: UpdateTokenPushUseCaseInput) throws -> UseCaseResponse<UpdateTokenPushUseCaseOkOutput, GenericUseCaseErrorOutput> {
        let bsanManagersProvider: BSANManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let compilation: CompilationProtocol = self.dependenciesResolver.resolve(for: CompilationProtocol.self)
        guard requestValues.oldTokenPush != requestValues.newTokenPush else {
            return .ok(UpdateTokenPushUseCaseOkOutput(tokenState: .match))
        }
        
        let oldToken = requestValues.oldTokenPush?.map { String(format: "%02.2hhx", $0) }.joined() ?? ""
        let newToken = requestValues.newTokenPush.map { String(format: "%02.2hhx", $0) }.joined()
        do {
            let response = try bsanManagersProvider.getBsanOTPPushManager().updateTokenPush(currentToken: oldToken, newToken: newToken)
            
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
