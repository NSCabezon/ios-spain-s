import UIKit
import RetailLegacy

@available(iOS 12.0, *)
class NoManagerViewController: UIViewController {
    var presenter: NoManagerPresenterProtocol?
    
    @IBOutlet private weak var noManagerTitle: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var actionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupData()
    }
    
    func setupView() {
        
        noManagerTitle.textColor = .sanRed
        noManagerTitle.font = .latoBold(size: 18.0)
        
        infoLabel.textColor = .sanGreyDark
        infoLabel.font = .latoLight(size: 14.0)
        
        separator.backgroundColor = .uiBackground
        
        actionLabel.textColor = .sanGreyDark
        actionLabel.font = .latoRegular(size: 16.0)
    
    }
    
    func setupData() {
        noManagerTitle.text = presenter?.title
        infoLabel.text = presenter?.info
        actionLabel.text = presenter?.action
    }
}
