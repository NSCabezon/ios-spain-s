protocol MifidAdvisoryClausesStepPresenterProtocol: Presenter {
    
}

class MifidAdvisoryClausesStepViewController: BaseViewController<MifidAdvisoryClausesStepPresenterProtocol> {
    override class var storyboardName: String {
        return "Mifid"
    }
    
    override func prepareView() {
        super.prepareView()
        
        view.backgroundColor = .sanGreyDark
        view.alpha = 0.5
    }
}

extension MifidAdvisoryClausesStepViewController: MifidView {}
