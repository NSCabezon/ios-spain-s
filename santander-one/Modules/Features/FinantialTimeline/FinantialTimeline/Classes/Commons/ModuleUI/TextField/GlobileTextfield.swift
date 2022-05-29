//
//  GlobileTextfield.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

enum GlobileFloatTextfieldState {
    case `default`
    case error
}

enum GlobileIconColors {
    case santanderRed, mediumGrey, darkGrey, darkSky
}

class GlobileTextfield: SantanderTextfield {

    // MARK: - Properties
    // Colors.
    enum Colors {
        enum BottomLine {
            static let `default` = UIColor.darkSky
        }
        static let `default` = UIColor.darkGray
        static let highlighted = UIColor.mediumSanGray
        static let error = UIColor.bostonRed
    }
    
    //Fonts.
    enum Fonts {
        static let `default` = UIFont.santanderText(type: .regular, with: 18)
        static let highlighted = UIFont.santanderText(type: .regular, with: 14)
        static let bottom = UIFont.santanderText(type: .regular, with: 14)
    }
    
    enum BackgroundMode {
        case sky, white
    }
    
    var iconColor: GlobileIconColors = .darkGrey {
        didSet {
            switch iconColor {
            case .darkGrey:
                tintColor = .darkGray
            case .santanderRed:
                tintColor = .sanRed
            case .darkSky:
                tintColor = .darkSky
            case .mediumGrey:
                tintColor = .mediumSanGray
            }
        }
    }

    //Sizes
    fileprivate let padding: CGFloat = 12.0
    fileprivate let bottomPlaceholderPadding: CGFloat = 2.0
    fileprivate let bottomPadding: CGFloat = 4.0
    fileprivate let buttonWidth: CGFloat = 24.0
    fileprivate let buttonPadding: CGFloat = 12.0
    
    //Constraints
    fileprivate var placeholderConstraint: NSLayoutConstraint!
    fileprivate var placeholderConstraintConstant: CGFloat!
    
    //State
    fileprivate var santanderState: GlobileFloatTextfieldState = .default
    
    //OnClicks
    fileprivate var iconAction: (() -> ())?
    fileprivate var clearAction: (() -> ())?
    
    fileprivate var hasContent: Bool {
        return !(text ?? "").isEmpty
    }
        
    var backgroundTheme: BackgroundMode = .white {
        didSet {
            switch backgroundTheme {
            case .white:
                backgroundColor = .white
            case .sky:
                backgroundColor = .lightSky
            }
        }
    }
    
    var showClearButton: Bool = true
    var rightIcon: UIImage? = nil {
        didSet {
            addRightIcon()
        }
    }
    private var rightConstraintWidth: NSLayoutConstraint!
    private var rightConstraintHeight: NSLayoutConstraint!

//    public var showInfotipButton: Bool = false {
//        didSet {
//            switch showInfotipButton {
//            case true:
//                infotipButton.isHidden = false
//            case false:
//                infotipButton.isHidden = true
//            }
//        }
//    }
//
    public var secureTextEntry: Bool = false {
        didSet {
            switch secureTextEntry {
            case true:
                self.isSecureTextEntry = true
            case false:
                self.isSecureTextEntry = false
            }
        }
    }
    
    var bottomText: String = ""
    
    override var text: String? {
        didSet {
            if (clearButton.isHidden == true && !isFirstResponder || (oldValue != "" && text == "" && !isFirstResponder)){
                animatePlaceholder()
            }
            configureRightView()
        }
    }
    
    @IBInspectable public var customPlaceholder: String? {
        didSet {
            setcustomPlaceholder()
        }
    }
    
    //MARK: Views
    fileprivate lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.BottomLine.default
        return view
    }()
    
    fileprivate lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.default
        label.textColor = Colors.highlighted
        return label
    }()
    
    fileprivate lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Fonts.bottom
        label.textColor = Colors.default
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    fileprivate lazy var rightStackview: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.spacing = buttonPadding
        sv.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 12)
        sv.isLayoutMarginsRelativeArrangement = true
        return sv
    }()
    
    fileprivate lazy var clearButton: GlobileButton = {
        let button = GlobileButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(fromModuleWithName: "clear")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = .lisboaGray
        button.isHidden = true
        button.onClick({ [weak self] in
            self?.clearText()
        })
        return button
    }()
    
    //TODO: Es el label el que tiene que reaccionar al click.
    fileprivate lazy var infotipButton: GlobileButton = {
        let button = GlobileButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(fromModuleWithName: "info")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.isHidden = true
        return button
    }()
    
    fileprivate lazy var separatorView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1.0, height: 28.0))
        view.backgroundColor = .mediumSky
        view.isHidden = true
        return view
    }()
    
    fileprivate lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
//        iv.tintColor = IconColors.darkGrey
        iv.isHidden = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setup()
        setcustomPlaceholder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setup()
        setcustomPlaceholder()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func textDidChange() {
        super.textDidChange()
        configureRightView()
        santanderState = .default
        stateDidChanged()
    }
    
    func onIconClick(_ action: (() -> Void)?) {
        self.iconAction = action
    }
    
    func onClearClick(_ action: (() -> Void)?) {
        self.clearAction = action
    }
}

// MARK: - Private methods.
extension GlobileTextfield {
    @objc private func clearText() {
        _ = becomeFirstResponder()
        text = ""
        santanderState = .default
        clearAction?()
    }
}

// MARK: - Public methods.
extension GlobileTextfield {
    
    func setPlaceholder(_ placeholder: String) {
        placeholderLabel.text = placeholder
    }
    
    func setcustomPlaceholder() {
        if let lab = customPlaceholder {
            placeholderLabel.text = lab
        }
    }
    
    func setBottomLabel(_ bottom: String, action: (() -> ())? = nil) {
        bottomLabel.text = bottom
        bottomText = bottom
    }
    
    func changeState(_ state: GlobileFloatTextfieldState) {
        bottomLabel.text = "Error! \(bottomText)"
        santanderState = state
        stateDidChanged()
    }
    
}

//MARK: Override methods and variables.
extension GlobileTextfield {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300.0, height: 48.0)
    }
    
    override var alignmentRectInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    override func becomeFirstResponder() -> Bool {
        animatePlaceholder(force: true)
        bottomLine.constraints.filter { $0.firstAttribute == .height }.first?.constant = 2
        self.layoutIfNeeded()
        santanderState = .default
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        bottomLine.constraints.filter { $0.firstAttribute == .height }.first?.constant = 1
        self.layoutIfNeeded()
        if text?.isEmpty ?? true {
            animatePlaceholder()
            configureRightView()
        }
        return super.resignFirstResponder()
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.y = bounds.maxY - (rightView?.bounds.maxY == 0 ? 32.0 : rightView?.bounds.maxY ?? buttonWidth) - bottomPadding
        return rect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 4.0, left: padding, bottom: 4.0, right: rightStackview.frame.width + 6.0))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 4.0, left: padding, bottom: 4.0, right: rightStackview.frame.width))
    }
    
}

//MARK: Configuration
extension GlobileTextfield {
    
    fileprivate func setup() {
        
        backgroundColor = .white
        borderStyle = .none
        contentVerticalAlignment = .bottom
        autocorrectionType = .no
        tintColor = .black
        
        textColor = Colors.default
        font = Fonts.default
        
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.mediumSky.cgColor
        
        if #available(iOS 11.0, *){
          layer.cornerRadius = 3
          layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
          let path = UIBezierPath(roundedRect: bounds,byRoundingCorners:[.topLeft, .topRight],cornerRadii: CGSize(width: 3, height:  3))
          let maskLayer = CAShapeLayer()
          maskLayer.path = path.cgPath
          layer.mask = maskLayer
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        iconImageView.isUserInteractionEnabled = true
        iconImageView.addGestureRecognizer(tapGestureRecognizer)

        addSubviews()
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        iconAction?()
    }
        
    func addSubviews() {
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomLine)
        addSubview(placeholderLabel)
        addSubview(bottomLabel)
        addSubview(infotipButton)
        
        rightStackview.addArrangedSubview(clearButton)
        rightStackview.addArrangedSubview(separatorView)
        rightStackview.addArrangedSubview(iconImageView)
        
        rightView = rightStackview

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: buttonWidth),
            separatorView.widthAnchor.constraint(equalToConstant: 1.0)
            ])
        
        NSLayoutConstraint.activate([
            bottomLine.leftAnchor.constraint(equalTo: leftAnchor),
            bottomLine.rightAnchor.constraint(equalTo: rightAnchor),
            bottomLine.topAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1.0)
            ])
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor),
            placeholderLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: padding),
            placeholderLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding),
            ])
        
        NSLayoutConstraint.activate([
            bottomLabel.topAnchor.constraint(equalTo: bottomLine.topAnchor, constant: 1),
            bottomLabel.leftAnchor.constraint(equalTo: leftAnchor),
            bottomLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            ])
        
        placeholderConstraint = placeholderLabel.bottomAnchor.constraint(equalTo: bottomLine.topAnchor, constant: -bottomPlaceholderPadding)
        placeholderConstraintConstant = placeholderConstraint.constant
        placeholderConstraint.isActive = true
    }
    
    
    fileprivate func animatePlaceholder(force: Bool? = nil) {
        
        let textHeight: CGFloat = (text ?? "").height(withConstrainedWidth: frame.width, font: Fonts.default)
        let newPadding: CGFloat = bottomPlaceholderPadding - textHeight

        if (!(force ?? hasContent)){
            maximizePlaceHolder(label: placeholderLabel)
        } else {
            if (hasContent){
                placeholderConstraint.constant = placeholderConstraintConstant + newPadding
                placeholderLabel.font = Fonts.highlighted
            } else {
                //Animate placeholder
                if (placeholderLabel.font.pointSize != 14){
                    minimizePlaceHolder(label: placeholderLabel, verticalTranslation: newPadding)
                }
            }
        }
        
        stateDidChanged(force: force ?? hasContent)
        layoutIfNeeded()
    }
    
    private func minimizePlaceHolder(label: UILabel, verticalTranslation: CGFloat) {
        let oldFrame = label.frame
        let newFrame = CGRect(x: label.frame.origin.x, y: label.frame.origin.y - 4.5, width: label.frame.width*14/18, height: label.frame.height*14/18)
        
        let translation = CGAffineTransform(translationX: newFrame.midX - oldFrame.midX,
                                            y: newFrame.midY - oldFrame.midY)
        let scaling = CGAffineTransform(scaleX: newFrame.width / oldFrame.width,
                                        y: newFrame.height / oldFrame.height)
        
        let transform = scaling.concatenating(translation)
        
        UIView.animate(withDuration: 0.2, animations: {
            label.transform = transform
        }) { _ in
            label.transform = .identity
            self.placeholderLabel.font = Fonts.highlighted
            self.placeholderConstraint.constant = self.placeholderConstraintConstant + verticalTranslation
        }
    }
    
    private func maximizePlaceHolder(label: UILabel) {
        
        let oldFrame = label.frame
        let newFrame = CGRect(x: label.frame.origin.x, y: label.frame.origin.y + 6.5, width: label.frame.width*18/14, height: label.frame.height*18/14)
        
        let translation = CGAffineTransform(translationX: newFrame.midX - oldFrame.midX,
                                            y: newFrame.midY - oldFrame.midY)
        let scaling = CGAffineTransform(scaleX: newFrame.width / oldFrame.width,
                                        y: newFrame.height / oldFrame.height)
        
        let transform = scaling.concatenating(translation)
        
        UIView.animate(withDuration: 0.2, animations: {
            label.transform = transform
        }) { _ in
            label.transform = .identity
            self.placeholderConstraint.constant = self.placeholderConstraintConstant
            self.placeholderLabel.font = Fonts.default
        }
    }
    
    fileprivate func stateDidChanged(force: Bool? = nil) {
        
        switch santanderState {
        case .default:
            bottomLine.backgroundColor = Colors.BottomLine.default
            bottomLabel.textColor = Colors.default
            placeholderLabel.textColor = Colors.highlighted
        case .error:
            bottomLine.backgroundColor = Colors.error
            bottomLabel.textColor = Colors.error
            placeholderLabel.textColor = Colors.error
        }
    }
    
    fileprivate func configureRightView() {
        
        if showClearButton {
            clearButton.isHidden = !hasContent
        }
       
        
        clearButton.frame = CGRect(x: 0, y: 0, width: 15.0, height: 34.0)
        separatorView.frame = CGRect(x: 0, y: 0, width: 1.0, height: 28.0)
        iconImageView.frame = CGRect(x: 0, y: 0, width: 24.0, height: 34.0)
        
        let noHiddenViews = rightStackview.arrangedSubviews.filter({ !$0.isHidden })
        
        var width: CGFloat = 0.0
        noHiddenViews.forEach({
            width += $0.frame.width
        })

        let spaces = noHiddenViews.count - 1
        if spaces > 0 {
            width += CGFloat(spaces) * buttonPadding
        }
        
        clearButton.contentMode = .scaleAspectFit
        separatorView.contentMode = .scaleAspectFit
        iconImageView.contentMode = .scaleAspectFit
        rightStackview.frame = CGRect(x: rightStackview.frame.origin.x, y: rightStackview.frame.origin.y, width: width + buttonPadding, height: 32)

        if rightConstraintHeight == nil {
            rightConstraintHeight = rightStackview.heightAnchor.constraint(equalToConstant: 32)
            rightConstraintHeight.isActive = true
        }

                
        if rightConstraintWidth == nil {
            rightConstraintWidth = rightStackview.widthAnchor.constraint(equalToConstant: width + buttonPadding)
            rightConstraintWidth.isActive = true
        }
        else {
            rightConstraintWidth.constant = width + buttonPadding
        }
        
        rightViewMode = .always

    }
    
    fileprivate func addRightIcon() {
        if let rightIcon = rightIcon {
            iconImageView.image = rightIcon.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            iconImageView.isHidden = false
            separatorView.isHidden = false
            iconColor = .mediumGrey
        }
        configureRightView()
    }
    
}

