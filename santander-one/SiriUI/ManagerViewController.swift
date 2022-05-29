import UIKit

@available(iOS 12.0, *)
class ManagerViewController: UIViewController {
    var presenter: ManagerPresenterProtocol?
    
    @IBOutlet private weak var managerTitle: UILabel!
    @IBOutlet private weak var separartor: UIView!
    @IBOutlet private weak var managerPhoto: UIImageView!
    @IBOutlet private weak var managerName: UILabel!
    @IBOutlet private weak var managerPhone: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        managerPhoto.layer.cornerRadius = managerPhoto.frame.width / 2.0
    }
    
    func setupView() {
        
        managerTitle.textColor = .sanRed
        managerTitle.font = .latoBold(size: 16.0)
        
        separartor.backgroundColor = .uiBackground
        
        managerName.textColor = .sanGreyDark
        managerName.font = .latoBold(size: 20.0)
        
        infoLabel.textColor = .sanGreyDark
        infoLabel.font = .latoLight(size: 14.0)
        
        managerPhone.textColor = .sanRed
        managerPhone.font = .latoBold(size: 20.0)
        
        managerPhoto.layer.borderColor = UIColor.sanRed.cgColor
        managerPhoto.layer.borderWidth = 1.0
    }
    
    func setupData() {
        if let photo = presenter?.photo {
            showManager(image: photo, container: managerPhoto)
        } else {
            managerPhoto.image = UIImage(named: "avatar_san")
        }
        managerTitle.text = presenter?.title
        managerName.text = presenter?.name
        managerPhone.text = presenter?.phone
        infoLabel.text = presenter?.info
    }
}
