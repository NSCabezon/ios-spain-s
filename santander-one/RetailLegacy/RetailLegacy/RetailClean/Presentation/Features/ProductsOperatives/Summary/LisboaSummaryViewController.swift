import UIKit
import Operative
import UI

final class LisboaSummaryViewController: BaseViewController<LisboaSummaryPresenterProtocol> {
    private weak var summaryViewController: SummaryStepViewController?
    override var progressBarBackgroundColor: UIColor? {
        return .sky30
    }
    override static var storyboardName: String {
        return "LisboaSummary"
    }
    
    override func viewDidLoad() {
        setupViews()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "genericToolbar_title_summary")
        )
        builder.setRightActions(.close(action: #selector(didTapClose)))
        builder.build(on: self, with: nil)
        
    }
    
    private func setupViews() {
        let summaryViewController: SummaryStepViewController = SummaryStepViewController()
        self.view.addSubview(summaryViewController.view)
        summaryViewController.view.translatesAutoresizingMaskIntoConstraints = false
        summaryViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        summaryViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        summaryViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        summaryViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.addChild(summaryViewController)
        summaryViewController.didMove(toParent: self)
        self.summaryViewController = summaryViewController
    }
    
    @objc func didTapClose() {
        presenter.didTapClose()
    }
    
    func configureView(title: String, header: [HeaderInfoSummaryModel], footer: [FooterInfoSummaryModel]) {
        summaryViewController?.configureView(title: title, header: header, footer: footer)
    }
}

extension LisboaSummaryViewController: OperativeStepViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
}
