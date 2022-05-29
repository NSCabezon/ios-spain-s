class CVVQueryCardPresenter: PrivatePresenter<CVVQueryCardViewController, VoidNavigator, CVVQueryCardPresenterProtocol> {
    var numberCipher: NumberCipher?
    
    override func loadViewData() {
        super.loadViewData()
        self.view.setupNavigationBarView()          
    }
    
    override func viewShown() {
        view.closeWithAnimation()
    }
}

extension CVVQueryCardPresenter: CVVQueryCardPresenterProtocol {
    var cvvNumber: String? {
        return numberCipher?.numberDecrypted
    }
}
