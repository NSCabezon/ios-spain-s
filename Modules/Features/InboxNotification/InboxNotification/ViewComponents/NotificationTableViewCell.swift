import UI
import CoreFoundationLib

protocol NotificationTableViewCellDelegate: class {
    func didTapCheck(isOn: Bool, index: Int)
    func tapDeleteNotification(index: Int)
    func swipeIsActivated(_ activated: Bool, atIndex index: Int)
}

final class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak private var checkButton: UIButton!
    @IBOutlet weak private var checkImageView: UIImageView! {
        didSet {
            checkImageView.image = Assets.image(named: "icnCheckEmpty")
        }
    }
    
    @IBOutlet weak private var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .santander(family: .text, type: .bold, size: 15.0)
            titleLabel.textColor = .lisboaGray
        }
    }
    @IBOutlet weak private var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = .santander(family: .text, type: .light, size: 14.0)
            descriptionLabel.textColor = .black
        }
    }
    @IBOutlet weak private var deleteImageView: UIImageView! {
        didSet {
            deleteImageView.image = Assets.image(named: "icnDelete")
        }
    }
    @IBOutlet weak private var deleteLabel: UILabel! {
        didSet {
            deleteLabel.font = .santander(family: .text, type: .regular, size: 13.0)
            deleteLabel.textColor = .gray
        }
    }
    @IBOutlet weak private var deleteView: UIView!
    @IBOutlet weak private var trailingConstraint: NSLayoutConstraint!
    
    weak var delegateNotification: NotificationTableViewCellDelegate?
    private var stateActivate = false
    private var index: Int = 0
    private var isDeleteEnable = false
    private var originalCenter = CGFloat.zero
    private var deleteOnDragRelease = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addGesturesEvent()
        backgroundColor = .skyGray
    }
    
    private func addGesturesEvent() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        let viewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapViewGesture))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        viewTapRecognizer.delegate = self
        addGestureRecognizer(viewTapRecognizer)
    }
    
    func setCellInfo(_ info: PushNotificationViewModel, index: Int) {
        var title = (info.title != "" ? info.title : localized("notificationMailbox_label_santander"))
        if info.date != "" { title += " • " + "\(info.date)" }
        titleLabel.text = title
        descriptionLabel.text = info.message
        if info.read {
            titleLabel.font = .santander(family: .text, type: .regular, size: 15.0)
        }
        stateActivate = info.isCheckSelected
        let image = stateActivate ? Assets.image(named: "icnCheckFull"): Assets.image(named: "icnCheckEmpty")
        checkImageView.image = image
        self.index = index
    }
    
    func setDeleteOption(title: String) {
        deleteLabel.text = title
    }
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        delegateNotification?.didTapCheck(isOn: stateActivate, index: index)
    }
    
    // Gestures
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let withDeleteConstraint = deleteView.frame.size.width
        switch recognizer.state {
        case .began:
            originalCenter = trailingConstraint.constant
        case .changed:
            let translation = recognizer.translation(in: self)
            trailingConstraint.constant = -min(deleteView.frame.size.width, translation.x - originalCenter)
            deleteOnDragRelease = trailingConstraint.constant > originalCenter + withDeleteConstraint * 0.5
        case .ended:
            let originalConstraint = CGFloat.zero
            if !deleteOnDragRelease {
                // if the swipe is not at least at medium way, goes to the origin
                UIView.animate(withDuration: 0.4, animations: { self.trailingConstraint.constant = originalConstraint})
                delegateNotification?.swipeIsActivated(false, atIndex: index)
                self.isDeleteEnable = false
            } else {
                UIView.animate(withDuration: 0.4, animations: { self.trailingConstraint.constant = withDeleteConstraint})
                delegateNotification?.swipeIsActivated(true, atIndex: index)
                self.isDeleteEnable = true
            }
        default:
            break
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            // Only to left at first
            if translation.x > 0 && trailingConstraint.constant == 0 {
                return false
            }
            if abs(translation.x) > abs(translation.y) {
                return true
            }
            
            return false
        }
        // When tapping inside the delete view
        if let tapGestureRecognizer = gestureRecognizer as? UITapGestureRecognizer,
           tapGestureRecognizer.location(in: deleteView).x > 0 && self.isDeleteEnable == true {
            return true
        }
        return false
    }
    
    func setSwipeProperly(_ activated: Bool) {
        let withDeleteConstraint = deleteView.frame.size.width
        trailingConstraint.constant = activated ? withDeleteConstraint : 0
    }
    
    @objc func handleTapViewGesture(recognizer: UITapGestureRecognizer) {
        delegateNotification?.tapDeleteNotification(index: index)
    }
}
