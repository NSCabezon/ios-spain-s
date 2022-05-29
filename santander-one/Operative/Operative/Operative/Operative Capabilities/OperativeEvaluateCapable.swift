public enum EvaluateBeforeShowing {
    case show
    case skip
    case showError(OperativeSetupError?, onErrorAcceptAction: () -> Void)
}

public protocol OperativeStepEvaluateCapable {
    func evaluateBeforeShowing(container: OperativeContainerProtocol?, action: @escaping (EvaluateBeforeShowing) -> Void)
}
