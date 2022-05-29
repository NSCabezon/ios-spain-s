import UIKit
import UI

protocol FakePGViewPresenterContract: Presenter {
    func backToLogin()
}

class FakePGViewController: BaseViewController<FakePGViewPresenterContract> {
    
    override class var storyboardName: String {
        return "GlobalPosition"
    }
    
    override var navigationBarStyle: NavigationBarBuilder.Style {
        return .clear(tintColor: .clear)
    }
    
    override func prepareView() {
        setCustomizeToolbar(isPB: false, name: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func resetNavigationBar() {
        navigationController?.navigationBar.setClearBackground(flag: true)
    }
}

extension FakePGViewController: NavigationBarPGCustomizer {}
