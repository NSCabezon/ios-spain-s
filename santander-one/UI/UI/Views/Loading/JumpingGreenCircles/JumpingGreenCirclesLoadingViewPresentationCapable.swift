import OpenCombine

public protocol JumpingGreenCirclesLoadingViewPresentationCapable {
    func showJumpingGreenLoadingPublisher() -> AnyPublisher<Void, Never>
    func dismissJumpingGreenLoadingPublisher() -> AnyPublisher<Void, Never>
    func dismissJumpingGreenLoading(completion: (() -> Void)?)
    var associatedLoadingView: UIViewController { get }
}

public extension JumpingGreenCirclesLoadingViewPresentationCapable where Self: UIViewController {
    var associatedLoadingView: UIViewController {
        return self
    }
}

extension JumpingGreenCirclesLoadingViewPresentationCapable {
    public func showJumpingGreenLoadingPublisher() -> AnyPublisher<Void, Never> {
        return Future { promise in
            JunmpingGreenCirclesLoadingCreator.showGlobalLoading(
                JumpingGreenCirclesLoadingViewController.Settings(
                    controller: associatedLoadingView,
                    completion: {
                        promise(.success(()))
                    }
                )
            )
        }.eraseToAnyPublisher()
    }
    
    public func dismissJumpingGreenLoadingPublisher() -> AnyPublisher<Void, Never> {
        return Future { promise in
            JunmpingGreenCirclesLoadingCreator.hideGlobalLoading {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    public func dismissJumpingGreenLoading(completion: (() -> Void)?) {
        JunmpingGreenCirclesLoadingCreator.hideGlobalLoading(completion: completion)
    }
}
