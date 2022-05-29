import UI

protocol CheckNotificationTableViewCellDelegate: class {
    func didTapCheckAll(isOn: Bool)
}

final class CheckNotificationTableViewCell: UITableViewCell {
    @IBOutlet weak private var checkButton: UIButton!
    
    @IBOutlet weak private var checkImageView: UIImageView! {
        didSet {
            checkImageView.image = Assets.image(named: "icnCheckEmpty")
        }
    }
    
    @IBOutlet weak private var notificationLabel: UILabel! {
        didSet {
            notificationLabel.font = .santander(family: .text, type: .bold, size: 16.0)
            notificationLabel.textColor = .lisboaGray
        }
    }
    
    @IBOutlet weak private var labelConstraint: NSLayoutConstraint!
    
    weak var delegate: CheckNotificationTableViewCellDelegate?
    private var stateActivate = false
    
    func setTitle(_ text: String) {
        notificationLabel.text = text
    }
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        refreshState()
        delegate?.didTapCheckAll(isOn: stateActivate)
    }
    
    func refreshState() {
        stateActivate = !stateActivate
        let image = stateActivate ? Assets.image(named: "icnCheckFull") : Assets.image(named: "icnCheckEmpty")
        checkImageView.image = image
    }
    
    func uncheck() {
        stateActivate = false
        let image = Assets.image(named: "icnCheckEmpty")
        checkImageView.image = image
    }
    
    func hideCheckButton(_ hide: Bool) {
        checkButton.isHidden = hide
        checkImageView.isHidden = hide
        labelConstraint.constant = hide ? 9 : 42
    }
}
