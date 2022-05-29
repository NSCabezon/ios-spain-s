import UI

final class CheckNotificationEmtpyTableViewCell: UITableViewCell {
    @IBOutlet weak private var leavesImageView: UIImageView! {
        didSet {
            leavesImageView.image = Assets.image(named: "imgLeaves")
        }
    }
    @IBOutlet weak private var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .santander(family: .headline, type: .regular, size: 20.0)
            titleLabel.textColor = .lisboaGray
            titleLabel.textAlignment = .center
        }
    }
    @IBOutlet weak private var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = .santander(family: .headline, type: .regular, size: 14.0)
            descriptionLabel.textColor = .lisboaGray
            descriptionLabel.textAlignment = .center
        }
    }
    
    func set(title: String, subtitle: String) {
        self.titleLabel.text = title
        self.descriptionLabel.text = subtitle
    }
}
