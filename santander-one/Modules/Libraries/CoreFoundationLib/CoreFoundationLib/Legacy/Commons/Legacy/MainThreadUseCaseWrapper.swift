import SANLegacyLibrary

public class MainThreadUseCaseWrapper<Input, Response, Error: StringErrorOutput> {
    @discardableResult
    public init(with useCase: UseCase<Input, Response, Error>, onSuccess: ((Response) -> Void)? = nil, onError: ((UseCaseError<Error>) -> Void)? = nil) {
        do {
            let responseUseCase: UseCaseResponse<Response, Error> = try useCase.run()
            if responseUseCase.isOkResult {
                onSuccess?(try responseUseCase.getOkResult())
            } else {
                onError?(.error(try responseUseCase.getErrorResult()))
            }
        } catch is WSUnauthorizedException {
            onError?(.unauthorized)
        } catch is BSANUnauthorizedException {
            onError?(.unauthorized)
        } catch is NetworkUnavailableException {
            onError?(.networkUnavailable)
        } catch is BSANNetworkException {
            onError?(.networkUnavailable)
        } catch is BSANIllegalStateException {
            onError?(.intern)
        } catch is RepositoryException {
            onError?(.generic)
        } catch is BSANServiceException {
            onError?(.generic)
        } catch is BSANServiceNoImplemented {
            onError?(.intern)
        } catch is UserInterruptedException {
            // thread interrupted
            // do nothing
        } catch {
            onError?(.generic)
        }
    }
}
