protocol Presenter {
    func loadViewData()
    func viewShown()
    func viewDisappear()
    func viewWillAppear()
    func viewWillDisappear()
}

protocol CloseButtonAwarePresenterProtocol {
    func closeButtonTouched()
}
