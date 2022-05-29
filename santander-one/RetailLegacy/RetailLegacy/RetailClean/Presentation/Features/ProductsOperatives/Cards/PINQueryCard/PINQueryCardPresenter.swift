final class PINQueryCardPresenter: PrivatePresenter<PINQueryCardViewController, VoidNavigator, PINQueryCardPresenterProtocol> {
    var numberCipher: NumberCipher?
        
    override func loadViewData() {
        super.loadViewData()
        self.view.setupNavigationBarView()        
    }
    
    override func viewShown() {
        view.closeWithAnimation()
    }
}

extension PINQueryCardPresenter: PINQueryCardPresenterProtocol {
    var pinNumber: String? {
        return numberCipher?.numberDecrypted
    }
}
