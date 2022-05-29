import UI
import CoreFoundationLib

final class ConfirmationContactDetailView: XibView {
    @IBOutlet weak private var avatarContainerView: UIView!
    @IBOutlet weak private var avatarLabel: UILabel!
    @IBOutlet weak private var pointLine: PointLine!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var thumbnailImageView: UIImageView!
    @IBOutlet weak private var stackView: UIStackView! {
        didSet {
            stackView.axis = .vertical
            stackView.spacing = 0.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    convenience init(_ viewModel: ConfirmationContactDetailViewModel) {
        self.init(frame: .zero)
        self.setupView()
        self.setupViewModel(viewModel)
    }
    
    func hidePointLine() {
        self.pointLine.isHidden = true
    }
}

private extension ConfirmationContactDetailView {
    func setupView() {
        let cornerRadius = self.avatarContainerView.layer.frame.width / 2
        self.avatarContainerView.drawBorder(cornerRadius: cornerRadius, color: .white, width: 1.0)
        self.avatarLabel.setSantanderTextFont(type: .bold, size: 15.0, color: .white)
        self.thumbnailImageView.layer.cornerRadius = cornerRadius
    }
    
    func setupViewModel(_ viewModel: ConfirmationContactDetailViewModel) {
        self.avatarContainerView.backgroundColor = viewModel.colorModel.color
        if let imageData = viewModel.thumbnailData {
            self.thumbnailImageView.image = UIImage(data: imageData)
            self.thumbnailImageView.isHidden = false
            self.avatarLabel.isHidden = true
        } else {
            self.avatarLabel.isHidden = false
            self.thumbnailImageView.isHidden = true
            self.avatarLabel.text = viewModel.initials
        }
        self.amountLabel.attributedText = viewModel.amountAttributeString
        if let alias = viewModel.alias {
            let label = UILabel()
            label.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
            label.numberOfLines = 2
            label.text = alias
            self.stackView.addArrangedSubview(label)
        }
        if let name = viewModel.name, !name.isEmpty, name != viewModel.alias {
            let label = UILabel()
            label.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
            label.numberOfLines = 2
            label.text = "(" + name + ")"
            self.stackView.addArrangedSubview(label)
        }
        let phoneLabel = UILabel()
        phoneLabel.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
        phoneLabel.text = viewModel.phone.tlfFormatted()
        self.stackView.addArrangedSubview(phoneLabel)
        let typeLabel = UILabel()
        typeLabel.setSantanderTextFont(type: .regular, size: 12.0, color: .grafite)
        typeLabel.text = viewModel.validateSendAction
        self.stackView.addArrangedSubview(typeLabel)
    }
}
