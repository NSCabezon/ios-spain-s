//
//  MultimediaContainerView.swift
import UI
import ESUI

enum MultimediaType {
    case image(_ image: Data, _ description: String)
    case note(_ description: String)
}

protocol MultimediaContainerViewDelegate: class {
    func showImage()
}

protocol MultimediaContainerViewProtocol {
    func updateView()
    func addOpenImageAction()
}

final class MultimediaContainerView: XibView {
    weak var delegate: MultimediaContainerViewDelegate?
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var attachedImageView: UIView!
    @IBOutlet private weak var attachedNoteView: UIView!
    @IBOutlet private weak var iconImage: UIImageView! {
        didSet {
            self.iconImage.drawBorder(cornerRadius: 5.0, color: .clear, width: 0.0)
            self.iconImage.contentMode = .scaleToFill
        }
    }
    @IBOutlet private weak var imageValueLabel: UILabel! {
        didSet {
            self.imageValueLabel.font = .santander(family: .text, type: .boldItalic, size: 14)
            self.imageValueLabel.textColor = .darkTorquoise
            self.imageValueLabel.accessibilityIdentifier = AccessibilityBizumDetail.bizumLabelmageText
        }
    }
    @IBOutlet private weak var iconNote: UIImageView! {
        didSet {
            self.iconNote.image = ESAssets.image(named: "icnNotes")
        }
    }
    @IBOutlet private weak var noteValueLabel: UILabel! {
        didSet {
            self.noteValueLabel.numberOfLines = 0
            self.noteValueLabel.font = .santander(family: .text, type: .italic, size: 14)
            self.noteValueLabel.textColor = .lisboaGray
            self.noteValueLabel.accessibilityIdentifier = AccessibilityBizumDetail.bizumLabelNoteValue
        }
    }
    @IBOutlet private weak var pointLine: PointLine!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private var topConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    func updateView(_ multimedia: [MultimediaType]) {
        self.topConstraint.isActive = false
        self.bottomConstraint.isActive = false
        self.pointLine.isHidden = false
        multimedia.forEach { (type) in
            switch type {
            case .image(let image, let description):
                self.attachedImageView.isHidden = false
                self.imageValueLabel.text = description
                self.iconImage.image = UIImage(data: image)
            case .note(let description):
                self.attachedNoteView.isHidden = false
                self.noteValueLabel.text = description
            }
        }
    }
}

private extension MultimediaContainerView {
    func configureView() {
        self.attachedImageView.isHidden = true
        self.attachedNoteView.isHidden = true
        self.pointLine.isHidden = true
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(showImage))
        self.attachedImageView.addGestureRecognizer(tapImageGesture)
    }

    @objc func showImage() {
        self.delegate?.showImage()
    }
}
