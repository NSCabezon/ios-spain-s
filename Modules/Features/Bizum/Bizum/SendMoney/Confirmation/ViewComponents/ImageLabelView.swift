import UI

final class ImageLabelView: XibView {
    @IBOutlet weak private var photoImageView: UIImageView!
    @IBOutlet weak private var label: UILabel!
    @IBOutlet weak private var pointLine: PointLine!
    @IBOutlet weak private var widthImageConstraint: NSLayoutConstraint!
    @IBOutlet weak private var heightImageConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setup(_ viewModel: ImageLabelViewModel) {
        self.widthImageConstraint.constant = viewModel.imageSize.width
        self.heightImageConstraint.constant = viewModel.imageSize.height
        self.photoImageView.image = viewModel.image
        self.label.text = viewModel.text
    }
    
    func showSeparator() {
        self.pointLine.isHidden = false
    }
}
private extension ImageLabelView {
    func setupView() {
        self.label.setSantanderTextFont(type: .italic, size: 14.0, color: .lisboaGray)
        self.pointLine.isHidden = true
        self.photoImageView.drawBorder(color: .clear)
        self.photoImageView.contentMode = .scaleToFill
    }
}
