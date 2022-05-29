extension PrivateHomeNavigatorImpl: BaseMenuViewControllerDelegate {
    func blackViewTouched() {
        goBack(animated: true)
    }
    
    func didSwipeSideMenu(_ isClosed: Bool) {
        guard isClosed else { return }
        popToFirstLevel(animated: false)
    }
}
