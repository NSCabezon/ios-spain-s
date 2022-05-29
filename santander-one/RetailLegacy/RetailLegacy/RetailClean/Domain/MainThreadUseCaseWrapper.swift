import SANLegacyLibrary
import CoreFoundationLib

class MainThreadUseCaseWrapper<Input, Response, Error: StringErrorOutput> {
    @discardableResult
    init(with useCase: UseCase<Input, Response, Error>, errorHandler: UseCaseErrorHandler? = nil, onSuccess: ((Response) -> Void)? = nil, onError: ((Error?) -> Void)? = nil) {
        do {
            let responseUseCase: UseCaseResponse<Response, Error> = try useCase.run()
            if responseUseCase.isOkResult {
                onSuccess?(try responseUseCase.getOkResult())
            } else {
                onError?(try responseUseCase.getErrorResult())
            }
        } catch is WSUnauthorizedException {
            errorHandler?.unauthorized()
        } catch is BSANUnauthorizedException {
            errorHandler?.unauthorized()
        } catch is NetworkUnavailableException {
            errorHandler?.showNetworkUnavailable()
        } catch is BSANNetworkException {
            errorHandler?.showNetworkUnavailable()
        } catch is BSANIllegalStateException {
            // do nothing
        } catch is RepositoryException {
            errorHandler?.showGenericError()
        } catch is BSANServiceException {
            errorHandler?.showGenericError()
        } catch is BSANServiceNoImplemented {
            // do nothing
        } catch is UserInterruptedException {
            // thread interrupted
            // do nothing
        } catch {
            errorHandler?.showGenericError()
        }
    }
}
