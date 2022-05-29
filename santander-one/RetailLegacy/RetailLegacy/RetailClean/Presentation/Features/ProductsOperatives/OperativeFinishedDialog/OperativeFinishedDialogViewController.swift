import UIKit

protocol OperativeFinishedDialogPresenterProtocol: Presenter {
}

class OperativeFinishedDialogViewController: BaseViewController<OperativeFinishedDialogPresenterProtocol> {
    
    override class var storyboardName: String {
        return "ProductOperatives"
    }
    
    func close(completion: @escaping () -> Void) {
        dismiss(animated: true, completion: completion)
    }
}
