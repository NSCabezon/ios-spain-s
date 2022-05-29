import UIKit

protocol Mifid2StepPresenterProtocol: Presenter {
}

class Mifid2StepViewController: BaseViewController<Mifid2StepPresenterProtocol> {
    override class var storyboardName: String {
        return "Mifid"
    }
    
    override func prepareView() {
        super.prepareView()
        
        view.backgroundColor = .sanGreyDark
        view.alpha = 0.0
    }
}

extension Mifid2StepViewController: MifidView {}
