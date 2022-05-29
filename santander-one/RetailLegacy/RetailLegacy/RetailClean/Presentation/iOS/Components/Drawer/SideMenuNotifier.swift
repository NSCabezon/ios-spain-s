final class SideMenuNotifier {
    private var delegates: [WeakReference<BaseMenuViewControllerDelegate>]

    public init() {
        self.delegates = []
    }
    
    func add(_ delegate: BaseMenuViewControllerDelegate) {
        let isAlreadyRefereneced = self.delegates.contains {
            return $0.reference === delegate
        }
        guard !isAlreadyRefereneced else { return }
        self.delegates.append(WeakReference(reference: delegate))
    }
    
    func blackViewTouched() {
        self.delegates = self.delegates.filter { $0.reference != nil }
        self.delegates.forEach { $0.reference?.blackViewTouched() }
    }
    
    func didSwipeSideMenu(isClosed: Bool) {
        self.delegates = self.delegates.filter { $0.reference != nil }
        self.delegates.forEach { $0.reference?.didSwipeSideMenu(isClosed) }
    }
    
    func removeList() {
        self.delegates = []
    }
}
