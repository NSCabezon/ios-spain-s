import Operative
import UI
import CoreFoundationLib

protocol EasyPaySummaryViewProtocol {
    func showComingSoonToast()
}

final class EasyPaySummaryViewController: OperativeSummaryViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    override func setupNavigationBar() {
        let titleImage = TitleImage(image: nil,
                                    topMargin: 4,
                                    width: 16,
                                    height: 16)
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithImage(key: "genericToolbar_title_summary",
                                   image: titleImage)
        )
        builder.build(on: self, with: nil)
    }
}

extension EasyPaySummaryViewController: EasyPaySummaryViewProtocol {
    func showComingSoonToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}
