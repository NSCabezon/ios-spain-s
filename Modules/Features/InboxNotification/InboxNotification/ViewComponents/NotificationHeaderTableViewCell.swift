import UI

protocol NotificationHeaderTableViewCellDelegate: class {
    func didTapLocation()
}

final class NotificationHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak private var contentViewHeader: UIView! {
        didSet {
            contentViewHeader.drawRoundedAndShadowedNew(widthOffSet: 0, heightOffSet: 0)
        }
    }
    @IBOutlet weak private var notificationLabel: UILabel! {
        didSet {
            notificationLabel.font = .santander(family: .text, type: .bold, size: 18.0)
            notificationLabel.textColor = .lisboaGray
        }
    }
    @IBOutlet weak private var settingImageView: UIImageView! {
        didSet {
            settingImageView.image = Assets.image(named: "icnRing")
        }
    }
    @IBOutlet weak private var arrowImageView: UIImageView! {
        didSet {
            arrowImageView.image = Assets.image(named: "icnArrowRight")
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setGestureEvent()
    }
    
    func setTitle(_ text: String) {
        notificationLabel.text = text
    }
    
    weak var delegate: NotificationHeaderTableViewCellDelegate?
    
    private func setGestureEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapOnView() {
        delegate?.didTapLocation()
    }
}
