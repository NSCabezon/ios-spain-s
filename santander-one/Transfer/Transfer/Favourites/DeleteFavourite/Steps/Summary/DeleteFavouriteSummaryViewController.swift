import Operative
import UI
import CoreFoundationLib

final class DeleteFavouriteSummaryViewController: OperativeSummaryViewController {
    private let presenter: DeleteFavouriteSummaryPresenterProtocol
    private var navigationBarTitle: String? {
        didSet {
            self.setupNavigationBar()
        }
    }
    
    init(presenter: DeleteFavouriteSummaryPresenterProtocol) {
        self.presenter = presenter
        super.init(presenter: presenter)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .sky, title: .title(key: self.navigationBarTitle ?? "genericToolbar_title_summary"))
        builder.setRightActions(.close(action: #selector(close)))
        builder.build(on: self, with: nil)
    }
}

private extension DeleteFavouriteSummaryViewController {
    @objc func close() {
        self.presenter.close()
    }
}
