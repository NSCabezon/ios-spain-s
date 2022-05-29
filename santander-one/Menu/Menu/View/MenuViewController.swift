import UIKit
import UI
import CoreFoundationLib

protocol MenuViewProtocol: AnyObject {
}

class MenuViewController: UIViewController {
    
    private let presenter: MenuPresenterProtocol

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: MenuPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension MenuViewController: MenuViewProtocol {
    
}
