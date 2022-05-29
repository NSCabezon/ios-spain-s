import UI
import CoreFoundationLib
import ESUI

final class BizumMultimediaView: XibView {
    var onImageTapped: () -> Void = {}
    var onDeleteNoteTapped: () -> Void = {}
    var onDeleteImageTapped: () -> Void = {}
    var noteWasUpdate: (String) -> Void = {_ in}
    var noteBeginEditing: () -> Void = {}
    var galleryActionsDelegate: BizumMultimediaGalleryDelegate?

    @IBOutlet weak var contentView: UIView!
    @IBOutlet private var contentNoteView: UIView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didSelectEdit))
            self.contentNoteView.addGestureRecognizer(gesture)
            self.contentNoteView.isUserInteractionEnabled = true
        }
    }
    @IBOutlet private var contentImageView: UIView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didSelectImage))
            self.contentImageView.addGestureRecognizer(gesture)
            self.contentImageView.isUserInteractionEnabled = true
        }
    }
    @IBOutlet private var separatorsView: [UIView]! {
        didSet {
            separatorsView.forEach { (view) in
                view.backgroundColor = .mediumSkyGray
            }
        }
    }
    @IBOutlet private weak var noteTitleLabel: UILabel! {
        didSet {
            self.noteTitleLabel.text = localized("generic_label_note")
            self.noteTitleLabel.font = .santander(family: .text, type: .bold, size: 16)
            self.noteTitleLabel.textColor = .lisboaGray
            self.noteTitleLabel.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumNoteTitle
        }
    }
    @IBOutlet private weak var iconNoteContainer: UIView!
    @IBOutlet private weak var iconNote: UIImageView! {
        didSet {
            self.iconNote.image = ESAssets.image(named: "icnNote")
        }
    }
    @IBOutlet private weak var noteTextView: UITextView! {
        didSet {
            self.noteTextView.font = .santander(family: .text, type: .italic, size: 14)
            self.noteTextView.textColor = .lisboaGray
            self.noteTextView.isScrollEnabled = false
            self.noteTextView.delegate = self
            self.noteTextView.text = localized("addNote_label_addNote")
            self.noteTextView.textContainer.lineFragmentPadding = 0
            self.noteTextView.textContainerInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
            self.noteTextView.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumNote
        }
    }
    @IBOutlet private weak var editButton: UIButton! {
        didSet {
            self.editButton.setImage(Assets.image(named: "icnEdit"), for: .normal)
            self.editButton.addTarget(self, action: #selector(didSelectEdit), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var deleteNoteButton: UIButton! {
        didSet {
            self.deleteNoteButton.setImage(ESAssets.image(named: "icnDelete2"), for: .normal)
            self.deleteNoteButton.addTarget(self, action: #selector(didSelectDeleteNote), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var imageTitleLabel: UILabel! {
        didSet {
            self.imageTitleLabel.text = localized("generic_label_image")
            self.imageTitleLabel.font = .santander(family: .text, type: .bold, size: 16)
            self.imageTitleLabel.textColor = .lisboaGray
            self.imageTitleLabel.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumImageTitle
        }
    }
    @IBOutlet private weak var iconImage: UIImageView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageWasTapped))
            self.iconImage.addGestureRecognizer(tapGesture)
            self.iconImage.isUserInteractionEnabled = true
            self.iconImage.contentMode = .scaleToFill
            self.iconImage.drawBorder(color: .clear)
        }
    }
    @IBOutlet private weak var imageValueLabel: UILabel! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageWasTapped))
            self.imageValueLabel.addGestureRecognizer(tapGesture)
            self.imageValueLabel.isUserInteractionEnabled = true
            self.imageValueLabel.text = localized("addImage_label_addImage")
            self.imageValueLabel.font = .santander(family: .text, type: .italic, size: 14)
            self.imageValueLabel.textColor = .lisboaGray
            self.imageValueLabel.accessibilityIdentifier = AccessibilityBizumSendMoney.bizumImage
        }
    }
    @IBOutlet private weak var cameraButton: UIButton! {
        didSet {
            self.cameraButton.setImage(ESAssets.image(named: "icnPhoto"), for: .normal)
            self.cameraButton.addTarget(self, action: #selector(didSelectImage), for: .touchUpInside)
        }
    }
    @IBOutlet private weak var deleteImageButton: UIButton! {
        didSet {
            self.deleteImageButton.setImage(ESAssets.image(named: "icnDelete2"), for: .normal)
            self.deleteImageButton.addTarget(self, action: #selector(didSelectDeleteImage), for: .touchUpInside)
        }
    }
    private let maxLength = 255

    @objc func didSelectEdit() {
        self.noteTextView.becomeFirstResponder()
    }

    @objc func didSelectImage() {
        self.onImageTapped()
    }

    @objc func didSelectDeleteNote() {
        self.noteTextView.resignFirstResponder()
        self.onDeleteNoteTapped()
    }

    @objc func didSelectDeleteImage() {
        self.onDeleteImageTapped()
    }
}

extension BizumMultimediaView: BizumMultimediaViewProtocol {
    func updateView() {
        self.showEdit()
        self.showCamera()
        self.hideDeleteNote()
        self.hideDeleteImage()
        self.hideThumbnailImage()
        self.hideNote()
    }
    
    func preloadNote(_ text: String) {
        self.noteTextView.text = text
        self.noteWasUpdate(noteTextView.text)
    }
    
    func setDescriptionNote(_ description: String) {
        self.noteTextView.text = description
    }
    func showNote() {
        self.iconNoteContainer.isHidden = false
    }
    func hideNote() {
        self.iconNoteContainer.isHidden = true
    }
    func showEdit() {
        self.editButton.isHidden = false
    }
    func hideEdit() {
        self.editButton.isHidden = true
    }
    func showDeleteNote() {
        self.deleteNoteButton.isHidden = false
    }
    func hideDeleteNote() {
        self.deleteNoteButton.isHidden = true
    }
    func showDeleteImage() {
        self.deleteImageButton.isHidden = false
    }
    func hideDeleteImage() {
        self.deleteImageButton.isHidden = true
    }
    func showCamera() {
        self.cameraButton.isHidden = false
    }
    func hideCamera() {
        self.cameraButton.isHidden = true
    }
    func showThumbnailImage(data: Data) {
        self.iconImage.isHidden = false
        self.iconImage.image = getThumbnail(imageData: data)
    }
    func hideThumbnailImage() {
        self.iconImage.isHidden = true
    }
    func setImageTitle(_ name: String) {
        self.imageValueLabel.text = name
    }
    func changeStyleNewImage() {
        self.imageValueLabel.textColor = .darkTorquoise
        self.imageValueLabel.font = .santander(family: .text, type: .bold, size: 14)
    }
    func changeStyleEmptyImage() {
        self.imageValueLabel.textColor = .lisboaGray
        self.noteTextView.textColor = .lisboaGray
        self.imageValueLabel.font = .santander(family: .text, type: .italic, size: 14)
    }
    func clearNoteTextColor() {
        self.noteTextView.textColor = .lisboaGray
    }
    func setNoteTextColorGrafite() {
        self.noteTextView.textColor = .grafite
    }
    func getThumbnail(imageData: Data) -> UIImage? {
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 300] as CFDictionary
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        return UIImage(cgImage: imageReference)
    }
}

extension BizumMultimediaView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.noteBeginEditing()
        self.showNote()
        if textView.textColor == .lisboaGray {
            textView.text = ""
            textView.textColor = .grafite
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.textViewEndEditing()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= maxLength
    }
}

private extension BizumMultimediaView {
    func configureView() {
        let tapView = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        self.addGestureRecognizer(tapView)
    }

    @objc func viewWasTapped() {
        self.resignFirstResponder()
    }

    func textViewEndEditing() {
        self.noteWasUpdate(noteTextView.text)
    }

    @objc func imageWasTapped() {
        self.onImageTapped()
    }
}
