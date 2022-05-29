//
//  GlobileAlertController.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

struct GlobileAlertAction {
    var title: String
    var style: GlobileEndingButtonStyle
    var action: () -> ()
    
    init(title: String, style: GlobileEndingButtonStyle, action: @escaping () -> ()) {
        self.title = title
        self.style = style
        self.action = action
    }
}


protocol ErrorHandlingDelegate: class {
    func answerPushed(answer: String)
}

class GlobileAlertController: UIViewController {
    weak var delegate: ErrorHandlingDelegate?
    private struct SantanderAlertRequest: Codable {
        var title: String
        var subtitle: String
        var message: String
        var positiveButtonText: String
        var negativeButtonText: String
    }
    private struct SantanderAlertResult: Codable {
        var code: Int
    }

    //Outlets
    let contentView: UIView = {
        let view = UIView()
        //background alert
        view.backgroundColor = .white
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .santanderHeadline(type: .bold, with: 18)
        label.textAlignment = .left
        label.text = "Title"
        label.textColor = .santanderRed
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(fromModuleWithName: "close")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .santanderRed
        return button
    }()
    
    let higherSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .santanderRed
        return view
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .santanderText(type: .regular, with: 16)
        label.textAlignment = .left
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .santanderText(type: .light, with: 16)
        label.textAlignment = .left
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    let lowerSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let buttonsStackview: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        sv.spacing = 16.0
        return sv
    }()
    
    var actions: [GlobileAlertAction] = []
    var completion: (() -> ())?
    
    convenience init(title: String? = nil, subtitle: String? = nil, message: String? = nil, actions: [GlobileAlertAction]? = nil, completion: (() -> ())? = nil) {
        self.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        messageLabel.text = message
        self.completion = completion
        modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if let actions = actions {
            self.actions = actions
            setupActions()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    var header: String?
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addAction(_ action: GlobileAlertAction) {
        actions.append(action)
        setupActions()
    }
    
    private func setupActions() {
        buttonsStackview.removeAllArrangedSubviews()
        for (index, action) in actions.prefix(2).enumerated() {
            let button = GlobileEndingButton()
            button.style = action.style
            button.setTitle(action.title, for: .normal)
            button.tag = index
            button.anchor(height: 44)
            button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonClicked(gesture:))))
            buttonsStackview.addArrangedSubview(button)
        }
    }
    
    @objc private func buttonClicked(gesture: UITapGestureRecognizer) {
        let index = (gesture.view as! UIButton).tag
        Array(actions)[index].action()
    }
    
    /// Function to perform hybrid actions
    ///
    /// - Parameter json: values to perform the hybrid action
    /// - Returns: output of the hybrid action
    @objc public func hybridInterface(_ json: String) -> String {
        guard let request = try? GlobileAlertController.decode(json, type: SantanderAlertRequest.self) else {
            return ""
        }
        titleLabel.text = request.title
        subtitleLabel.text = request.subtitle
        messageLabel.text = request.message
        modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if !request.negativeButtonText.isEmpty {
            actions.append(GlobileAlertAction(title: request.negativeButtonText, style: .secondary, action: {
                self.delegate?.answerPushed(answer: try! GlobileAlertController.encode(SantanderAlertResult(code: 2)))
                self.dismiss(animated: true)

            }))
        }
        if !request.positiveButtonText.isEmpty {
            actions.append(GlobileAlertAction(title: request.positiveButtonText, style: .primary) {
                self.delegate?.answerPushed(answer: try! GlobileAlertController.encode(SantanderAlertResult(code: 1)))
                self.dismiss(animated: true)
            })
        }
        setupActions()
        return ""
    }
}

//Setup Views
extension GlobileAlertController {
    private func setupView() {
        //background view
        view.backgroundColor = .black
        view.addSubview(contentView)
        setupContentView()
        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
        contentView.addSubview(higherSeparatorView)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(lowerSeparatorView)
        contentView.addSubview(buttonsStackview)
        setupTitleLabel()
        setupCloseButton()
        setupHigherSeparatorView()
        setupSubtitleLabel()
        setupMessageLabel()
        setupLowerSeparatorView()
        setupButtonsStackview()
        closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeButtonTouchUpInside(_:))))
        modalPresentationStyle = .overCurrentContext
    }
    
    @objc private func closeButtonTouchUpInside(_ gesture: UITapGestureRecognizer) -> String {
        dismiss(animated: true, completion: completion)
        delegate?.answerPushed(answer: try! GlobileAlertController.encode(SantanderAlertResult(code: 3)))
        return try! GlobileAlertController.encode(SantanderAlertResult(code: 3))
    }
    
    private func setupContentView() {
        contentView.layer.cornerRadius = 5.0
        contentView.anchor(left: view.leftAnchor, right: view.rightAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16))
        contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
    }
    
    private func setupTitleLabel() {
        titleLabel.anchor(left: contentView.leftAnchor, top: contentView.topAnchor, padding: UIEdgeInsets(top: 9, left: 16, bottom: 0, right: 0))
    }
    
    private func setupCloseButton() {
        closeButton.anchor(top: contentView.topAnchor, right: contentView.rightAnchor, bottom: higherSeparatorView.topAnchor, width: 24, height: 24, padding: UIEdgeInsets(top: 16, left: 0, bottom: -16, right: -16))
    }
    
    private func setupHigherSeparatorView() {
        higherSeparatorView.anchor(left: contentView.leftAnchor, top: titleLabel.bottomAnchor, right: contentView.rightAnchor, height: 1.0, padding: UIEdgeInsets(top: 9, left: 0, bottom: 0, right: 0))
    }
    
    private func setupSubtitleLabel() {
        subtitleLabel.anchor(left: contentView.leftAnchor, top: higherSeparatorView.bottomAnchor, right: contentView.rightAnchor, padding: UIEdgeInsets(top: 9, left: 16, bottom: 0, right: -16))
    }
    
    private func setupMessageLabel() {
        messageLabel.anchor(left: contentView.leftAnchor, top: subtitleLabel.bottomAnchor, right: contentView.rightAnchor, padding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: -16))
    }
    
    private func setupLowerSeparatorView() {
        lowerSeparatorView.anchor(left: contentView.leftAnchor, top: messageLabel.bottomAnchor, right: contentView.rightAnchor, height: 1.0, padding: UIEdgeInsets(top: 9, left: 0, bottom: 0, right: 0))
    }
    
    private func setupButtonsStackview() {
        buttonsStackview.anchor(left: contentView.leftAnchor, top: lowerSeparatorView.bottomAnchor, right: contentView.rightAnchor, bottom: contentView.bottomAnchor, padding: UIEdgeInsets(top: 16, left: 8, bottom: -16, right: -8))
    }
    
    private static func decode<T: Codable>(_ json: String, type: T.Type) throws -> T  {
        guard let data = json.data(using: .utf8) else {
            throw NSError(domain: "Unable to parse action", code: 1, userInfo: nil)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private static func encode<T: Codable>(_ result: T) throws -> String {
        let data = try JSONEncoder().encode(result)
        if let result = String(data: data, encoding: .utf8) {
            return result
        }
        throw NSError(domain: "JSON could't be encoded into a string.", code: 1, userInfo: nil)
    }
}
