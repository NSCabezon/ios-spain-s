protocol OperativeLauncherPresentationDelegate: class {
    func startOperativeLoading(completion: @escaping () -> Void)
    func hideOperativeLoading(completion: @escaping () -> Void)
    func showOperativeAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?)
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?)
    var errorOperativeHandler: GenericPresenterErrorHandler { get }
}
