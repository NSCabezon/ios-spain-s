import UI
import CoreFoundationLib

final class BizumImageViewerViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.text = localized("toolbar_title_attachedImage")
            self.titleLabel.font = .santander(family: .text, type: .bold, size: 18)
            self.titleLabel.textColor = .lisboaGray
        }
    }
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var closeButton: UIButton! {
        didSet {
            let image = Assets.image(named: "icnCloseGray")?.withRenderingMode(.alwaysTemplate)
            self.closeButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
            self.closeButton.setImage(image, for: .normal)
            self.closeButton.tintColor = .brownGray
        }
    }
    private let image: Data

    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         image: Data) {
        self.image = image
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = UIImage(data: self.image)
    }

    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}
