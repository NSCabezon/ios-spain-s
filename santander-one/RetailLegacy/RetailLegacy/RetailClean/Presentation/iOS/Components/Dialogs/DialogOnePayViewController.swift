import UIKit
import UI

protocol DialogOnePayPresenterProtocol: Presenter {
    var titleText: LocalizedStylableText { get }
    var imageName: String { get }
    var texts: [LocalizedStylableText] { get }
    var standarButtonComponents: DialogButtonComponents { get }
    var immediateButtonComponents: DialogButtonComponents { get }
}

class DialogOnePayViewController: BaseViewController<DialogOnePayPresenterProtocol> {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelStack: UIStackView!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeButton: ResponsiveStateButton!
    
    private enum Constants {
        static let closeButtonImage = "icnCloseModal"
    }
    
    override class var storyboardName: String {
        return "TransferOperatives"
    }
    
    override func prepareView() {
        super.prepareView()
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 4
        
        setupView()
    }
    
    private func setupView() {
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 16), textAlignment: .left))
        titleLabel.set(localizedStylableText: presenter.titleText)
        imageView.image = Assets.image(named: presenter.imageName)
        setContent(texts: presenter.texts)
        setButtons()
    }
    
    //! Fill contents with "•" and indent to it by stackview
    private func setContent(texts: [LocalizedStylableText]) {
        for text in texts {
            let circleLabel = UILabel()
            circleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoLight(size: 16)))
            circleLabel.text = "•"
            let textLabel = UILabel()
            textLabel.numberOfLines = 0
            textLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16)))
            textLabel.set(localizedStylableText: text)
            let horizontalStackView = UIStackView(arrangedSubviews: [circleLabel, textLabel])
            horizontalStackView.axis = .horizontal
            horizontalStackView.alignment = .firstBaseline
            horizontalStackView.distribution = .equalSpacing
            horizontalStackView.backgroundColor = .clear
            labelStack.addArrangedSubview(horizontalStackView)
            let width = NSLayoutConstraint(item: circleLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 14)
            width.priority = .required
            width.isActive = true
            let top = NSLayoutConstraint(item: horizontalStackView, attribute: .top, relatedBy: .equal, toItem: circleLabel, attribute: .top, multiplier: 1, constant: 0)
            top.priority = .required
            top.isActive = true
            let rigth = NSLayoutConstraint(item: circleLabel, attribute: .right, relatedBy: .equal, toItem: textLabel, attribute: .left, multiplier: 1, constant: 0)
            rigth.priority = .required
            rigth.isActive = true
        }
        viewDidLayoutSubviews()
    }
    
    private func setButtons() {
        // Standar transfer
        let standard = presenter.standarButtonComponents
        let standardButton = WhiteButton(type: .custom)
        standardButton.onTouchAction = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: standard.action)
        }
        standardButton.set(localizedStylableText: standard.title, state: .normal)
        standardButton.configureHighlighted(font: .latoMedium(size: 16))
        standardButton.adjustTextIntoButton()
        buttonStack.addArrangedSubview(standardButton)
        
        // Immediate transfer
        let immediate = presenter.immediateButtonComponents
        let immediateButton = RedButton(type: .custom)
        immediateButton.onTouchAction = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: immediate.action)
        }
        immediateButton.titleLabel?.font = .latoRegular(size: 16)
        immediateButton.set(localizedStylableText: immediate.title, state: .normal)
        immediateButton.adjustTextIntoButton()
        immediateButton.labelButtonLines()
        immediateButton.setTextAligment(.center, for: .normal)
        buttonStack.addArrangedSubview(immediateButton)
        
        closeButton.setImage(Assets.image(named: Constants.closeButtonImage), for: .normal)
    }
    
    @IBAction func closeButtonAction(_ sender: ResponsiveButton) {
        dismiss(animated: true)
    }
}
