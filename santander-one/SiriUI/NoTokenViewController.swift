import UIKit

@available(iOS 12.0, *)
class NoTokenViewController: UIViewController {
    var presenter: NoTokenPresenterProtocol?
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var bottomLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupData()
    }
    
    func setupView() {
        titleLabel.textColor = .sanRed
        titleLabel.font = .latoBold(size: 16.0)
        
        separator.backgroundColor = .uiBackground
        
        messageLabel.textColor = .sanGreyDark
        messageLabel.font = .latoLight(size: 12.0)
        
        bottomLabel.textColor = .sanGreyDark
        bottomLabel.font = .latoBold(size: 14.0)
    }
    
    func setupData() {
        titleLabel.text = presenter?.title
        messageLabel.text = presenter?.message
        bottomLabel.text = presenter?.bottom
    }
}
