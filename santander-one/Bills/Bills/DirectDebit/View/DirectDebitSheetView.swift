import UIKit
import UI
import CoreFoundationLib

protocol DirectDebitViewProtocol: AnyObject {
    func setDirectDebitViewModels(_ viewModels: [DirectDebitActionViewModel])
}

class DirectDebitSheetView: SheetView {
    
    let presenter: DirectDebitPresenterProtocol
    
    init(presenter: DirectDebitPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func load() {
        self.presenter.viewDidLoad()
    }
}

extension DirectDebitSheetView: DirectDebitViewProtocol {
    
    func setDirectDebitViewModels(_ viewModels: [DirectDebitActionViewModel]) {
        let directDebitView = DirectDebitView()
        directDebitView.delegate = self
        directDebitView.setViewModels(viewModels)
        self.removeContent()
        self.addContentView(directDebitView)
        self.show()
    }
}

extension DirectDebitSheetView: DirectDebitViewDelegate {
    func didSelectOpenUrl(with url: String) {
        self.closeWithAnimation()
        self.presenter.didSelectOpenUrl(with: url)
    }
    
    func didSelectDirectDebit() {
        self.closeWithAnimationAndCompletion { [weak self] in
            self?.presenter.didSelectDirectDebit()
        }
    }
}
