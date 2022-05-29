import UIKit
import UI

class GenericLandingPushHeaderView: UIView {
    
    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santanderTextBold(size: 24.0)
        label.numberOfLines = 2
        label.textColor = .sanGreyDark
        
        return label
    }()
    
    private let subtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont.santanderTextLight(size: 22.0)
        label.textColor = .deepSanGrey
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
    }()
    
    private let bottomText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santanderTextLight(size: 56.0)
        label.textColor = .sanGreyDark
        label.textAlignment = .center
        
        return label
    }()
    
    private let backgroundedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(patternImage: Assets.image(named: "backgroundTile")!)
        
        return view
    }()
    
    private var genericLandingInfoView: GenericLandingPushDescriptionView?
    
    private let titlesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 25, left: 10, bottom: 20, right: 10)
        
        return stackView
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        setupBackground()
        titlesStackView.addArrangedSubview(title)
        titlesStackView.addArrangedSubview(subtitle)
        containerStackView.embedInto(container: self, insets: UIEdgeInsets(top: 0, left: 10, bottom: -20, right: -10))
        containerStackView.addArrangedSubview(titlesStackView)
        containerStackView.addArrangedSubview(backgroundedView)
        containerStackView.addArrangedSubview(bottomText)

        backgroundColor = .clear
        
        self.layer.shadowColor = UIColor.uiBlack.cgColor
        self.layer.shadowOpacity = 0.40
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
    }
    
    private func setupBackground() {
        let bottomImageView = UIImageView()
        bottomImageView.translatesAutoresizingMaskIntoConstraints = false
        let backgroundView = UIView()
        backgroundView.backgroundColor = .uiWhite
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        bottomImageView.image = Assets.image(named: "abajo")
        let topImageView = UIImageView()
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        topImageView.image = Assets.image(named: "arriba")
        
        let stackView = UIStackView()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        
        stackView.addArrangedSubview(topImageView)
        stackView.addArrangedSubview(backgroundView)
        stackView.addArrangedSubview(bottomImageView)
        
        stackView.embedInto(container: self)
    }
    
    func setupWith(_ info: GenericLandingPushHeaderType) {
        if let titleText = info.title {
            title.set(localizedStylableText: titleText)
        }
        title.isHidden = info.title == nil
        subtitle.configureText(withLocalizedString: info.subtitle)
        setAmount(info.amount)
    }
    
    func setAmount(_ amount: String?) {
        bottomText.isHidden = amount == nil
        bottomText.text = amount
        bottomText.scaleDecimals()
    }
    
    func setBackgroundedContent(_ view: GenericLandingPushDescriptionView) {
        backgroundedView.subviews.forEach { $0.removeFromSuperview() }
        view.embedInto(container: backgroundedView)
        genericLandingInfoView = view
    }
}
