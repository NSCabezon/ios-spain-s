import CoreFoundationLib

public final class CardImageNameAndPanView: XibView {
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var cardTitleLabel: UILabel!

    private let defaultImage = Assets.image(named: "defaultCard")
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func configView(_ title: String, imageUrl: String?) {
        handleCardImage(imageUrl)
        let configuration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14), alignment: .left)
        cardTitleLabel.configureText(withKey: title, andConfiguration: configuration)
    }
}

private extension CardImageNameAndPanView {
    func setupView() {
        backgroundColor = .clear
        setTitleLabel()
    }
    
    func handleCardImage(_ imageUrl: String?) {
        if let imageUrl = imageUrl {
            cardImageView.loadImage(urlString: imageUrl,
                                    placeholder: defaultImage,
                                    completion: nil)
        } else {
            cardImageView.image = defaultImage
        }
    }
    
    func setTitleLabel() {
        cardTitleLabel.textColor = .grafite
        cardTitleLabel.numberOfLines = 1
    }
}
