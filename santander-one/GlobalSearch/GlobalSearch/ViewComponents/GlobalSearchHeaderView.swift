//
//  GlobalSearchHeaderView.swift
//  GlobalSearch
//
//  Created by César González Palomino on 24/02/2020.
//

import UI

protocol GlobalSearchHeaderViewDelegate: class {
    func textFieldDidSet(text: String)
    func touchAction()
    func clearIconAction()
}

final class GlobalSearchHeaderView: UIView {
    
    private var container: UIView
    
    private lazy var topView: SearchFieldView = {
        let view = SearchFieldView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    weak var delegate: GlobalSearchHeaderViewDelegate?
    
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
    
    override func becomeFirstResponder() -> Bool {
        return topView.textField.becomeFirstResponder()
    }
    
    func updateTexField(text: String) {
        topView.textField.updateData(text: text)
    }
    
    // MARK: - privateMethods
    
    private func setup() {
        heightAnchor.constraint(equalToConstant: 78.0).isActive = true
        topView.fullFit()
        topView.backgroundColor = .skyGray
        topView.textField.accessibilityIdentifier = "GlobalSearchInputTextSearch"
        
        topView.textFieldAction = { [weak self] text in
            self?.delegate?.textFieldDidSet(text: text)
        }
        
        topView.clearIconAction = { [weak self] in
            self?.delegate?.clearIconAction()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        delegate?.touchAction()
    }
}
