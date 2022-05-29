public typealias OperativeSetupError = (title: String?, message: String?)

public protocol OperativePresetupCapable {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void)
}

public protocol OperativeSetupCapable {
    func performSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void)
}
