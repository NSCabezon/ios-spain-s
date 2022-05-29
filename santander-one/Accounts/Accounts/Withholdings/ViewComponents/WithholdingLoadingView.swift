import UI

class WithholdingLoadingView: XibView {
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var separatorView: DottedLineView!

    convenience init(_ viewModel: WithholdingLoadingViewModel) {
        self.init(frame: .zero)
        self.setViewModel(viewModel)
        self.setAppearance()
    }
    
    private func setAppearance() {
        self.separatorView?.strokeColor = .darkSky
        self.startAnimation()
    }
    
    private func setViewModel(_ viewModel: WithholdingLoadingViewModel) {
        self.loadingLabel.text = viewModel.title
    }
    
    func startAnimation() {
        self.loadingImageView.setPointsLoader()
    }
    
    func stopAnimation() {
        self.loadingImageView.removeLoader()
    }
    
    public func setAccessibilityIdentifiers(imgAccessibilityID: String, labelAccessibilityID: String) {
        self.loadingImageView.accessibilityIdentifier = imgAccessibilityID
        self.loadingLabel.accessibilityIdentifier = labelAccessibilityID
    }
}
