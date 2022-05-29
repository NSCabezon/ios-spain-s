//
//  BizumNGOSearchTextFieldView.swift
//  Bizum
import UI
import CoreFoundationLib

public protocol BizumNGOSearchTextFieldViewDelegate: class {
    func textFieldDidSet(text: String)
    func touchAction()
    func clearIconAction()
}

public class BizumNGOSearchTextFieldView: UIView {
    
    private var container: UIView
    
    private lazy var topView: SearchFieldView = {
        let view = SearchFieldView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    private lazy var transparentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.fullFit()
        bringSubviewToFront(view)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        return view
    }()

    public weak var delegate: BizumNGOSearchTextFieldViewDelegate?
    
    public override var isFirstResponder: Bool {
        return topView.textField.isFirstResponder
    }
    
    override init(frame: CGRect) {
        self.container = UIView(frame: .zero)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func becomeFirstResponder() -> Bool {
        return topView.textField.becomeFirstResponder()
    }
    
    public func updateTexField(text: String) {
        topView.textField.updateData(text: text)
    }
    
    public func setupIdentifier(_ identifier: String) {
        topView.textField.accessibilityIdentifier = identifier
    }
    
    public func updateTitle(_ title: String?) {
        self.topView.updateTitle(title)
    }
    
    public func disableView() {
        transparentView.isHidden = false
    }
    
    public func enableView() {
        transparentView.isHidden = true
    }
    
    // MARK: - privateMethods
    private func setup() {
        heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        topView.fullFit()
        var textFieldStyle: LisboaTextFieldStyle = topView.defaultSearchTextFieldStyle
        textFieldStyle.containerViewBorderColor = UIColor.mediumSkyGray.cgColor
        textFieldStyle.containerViewBackgroundColor = UIColor.skyGray
        textFieldStyle.fieldBackgroundColor = UIColor.skyGray
        textFieldStyle.extraInfoViewBackgroundColor =  UIColor.skyGray
        textFieldStyle.verticalSeparatorBackgroundColor = UIColor.darkTurqLight
        textFieldStyle.extraInfoHorizontalSeparatorBackgroundColor = UIColor.atmsShadowGray
        topView.configure(with: nil,
                          title: localized("bizum_hint_writeOrganization"),
                          style: textFieldStyle,
                          extraInfo: (Assets.image(named: "icnSearch"), action: nil),
                          isNeededFloatingTitle: false)
        topView.textFieldAction = { [weak self] text in
            self?.delegate?.textFieldDidSet(text: text)
        }
        topView.clearIconAction = { [weak self] in
            self?.delegate?.clearIconAction()
        }
        enableView()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        delegate?.touchAction()
    }
}
