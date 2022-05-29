//
//  InputCodeView.swift
//  UI
//
//  Created by Angel Abad Perez on 20/12/21.
//

public protocol InputCodeViewDelegate: AnyObject {
    func codeView(_ view: InputCodeView, didChange string: String, for position: Int)
    func codeView(_ view: InputCodeView, willChange string: String, for position: Int) -> Bool
    func codeView(_ view: InputCodeView, didBeginEditing position: Int)
    func codeView(_ view: InputCodeView, didEndEditing position: Int)
}

public enum RequestedPositions {
    case all
    case positions([Int])

    func isRequestedPosition(position: Int) -> Bool {
        switch self {
        case .all:
            return true
        case .positions(let positions):
            return positions.contains(where: { $0 == position })
        }
    }
}

public class InputCodeView: UIView {
    public let charactersSet: CharacterSet
    private var inputCodeBoxArray = [InputCodeBoxView]()
    private weak var delegate: InputCodeViewDelegate?
    private var keyboardType: UIKeyboardType
    private let facade: InputCodeFacadeProtocol

    public init(keyboardType: UIKeyboardType = .default,
                delegate: InputCodeViewDelegate?,
                facade: InputCodeFacadeProtocol,
                elementSize: CGSize,
                requestedPositions: RequestedPositions,
                charactersSet: CharacterSet) {
        self.facade = facade
        self.keyboardType = keyboardType
        self.delegate = delegate
        self.charactersSet = charactersSet
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.configureInputCodeBoxArray(facade: facade,
                                        elementSize: elementSize,
                                        requestedPositions: requestedPositions)
        self.addSubviews(view: self.facade.view(with: self.inputCodeBoxArray))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult override public func resignFirstResponder() -> Bool {
        self.inputCodeBoxArray.isAnyFirstResponder()?.resignFirstResponder()
        return true
    }

    public func firstEmptyRequested() -> Int? {
        guard let nextEmptyBox = self.inputCodeBoxArray.firstEmptyRequested() else { return nil }
        return nextEmptyBox.position
    }

    public func fulfilledText() -> String? {
        return self.inputCodeBoxArray.fulfilledText()
    }

    public func isFulfilled() -> Bool {
        return self.inputCodeBoxArray.fulfilledCount() == self.inputCodeBoxArray.requestedCount()
    }

    @discardableResult public override func becomeFirstResponder() -> Bool {
        guard let first = self.inputCodeBoxArray.firstEmptyRequested() else { return false }
        return first.becomeFirstResponder()
    }
    
    public func setBoxView(position: NSInteger, backgroundColor: UIColor, borderWidth: CGFloat, borderColor: UIColor) {
        let boxView = self.inputCodeBoxArray[position - 1]
        boxView.layer.borderWidth = borderWidth
        boxView.layer.borderColor = borderColor.cgColor
        boxView.backgroundColor = backgroundColor
        switch boxView.getPosition() {
        case .first:
            if #available(iOS 11.0, *) {
                boxView.layer.cornerRadius = 6
                boxView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            } else {
                boxView.roundCorners(corners: [.bottomLeft, .topLeft], radius: 6)
            }
        case .last:
            if #available(iOS 11.0, *) {
                boxView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                boxView.layer.cornerRadius = 6
            } else {
                boxView.roundCorners(corners: [.bottomRight, .topRight], radius: 6)
            }
        default:
            break
        }
    }
    
    public func reset() {
        self.inputCodeBoxArray.reset()
    }
}

private extension InputCodeView {
    func configureInputCodeBoxArray(facade: InputCodeFacadeProtocol,
                                    elementSize: CGSize,
                                    requestedPositions: RequestedPositions) {
        let facadeConfiguration = facade.configuration()
        for position in 1...facadeConfiguration.elementsNumber {
            self.inputCodeBoxArray.append(InputCodeBoxView(position: position,
                                                           showPosition: facadeConfiguration.showPositions,
                                                           elementsNumber: facadeConfiguration.elementsNumber,
                                                           delegate: self,
                                                           requested: requestedPositions.isRequestedPosition(position: position),
                                                           isSecureEntry: facadeConfiguration.showSecureEntry,
                                                           size: elementSize,
                                                           font: facadeConfiguration.font,
                                                           textColor: facadeConfiguration.textColor,
                                                           cursorTintColor: facadeConfiguration.cursorTintColor,
                                                           cursorHeight: facadeConfiguration.cursorHeight,
                                                           borderColor: facadeConfiguration.borderColor,
                                                           borderWidth: facadeConfiguration.borderWidth))
        }
    }

    func addSubviews(view: UIView) {
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}

extension InputCodeView: InputCodeBoxViewDelegate {
    func codeBoxViewShouldChangeString (_ codeBoxView: InputCodeBoxView, replacementString string: String) -> Bool {
        let allowChange = self.delegate?.codeView(self, willChange: string, for: codeBoxView.position)
        guard allowChange == true else {
            codeBoxView.text = ""
            return false
        }
        if string.isBackSpace {
            return true
        }
        codeBoxView.text = string
        self.delegate?.codeView(self, didChange: string, for: codeBoxView.position)
        if let nextPasswordInputBoxView = self.inputCodeBoxArray.nextEmptyRequested(from: codeBoxView.position) {
            nextPasswordInputBoxView.becomeFirstResponder()
        } else {
            codeBoxView.resignFirstResponder()
        }
        return true
    }

    func codeBoxViewDidBeginEditing (_ codeBoxView: InputCodeBoxView) {
        let firstEmptyRequested = self.inputCodeBoxArray.firstEmptyRequested()
        if codeBoxView.isEmpty && firstEmptyRequested != codeBoxView {
            firstEmptyRequested?.becomeFirstResponder()
        } else {
            codeBoxView.setKeyboardType(self.keyboardType)
            self.delegate?.codeView(self, didBeginEditing: codeBoxView.position)
        }
    }

    func codeBoxViewDidEndEditing (_ codeBoxView: InputCodeBoxView) {
        self.delegate?.codeView(self, didEndEditing: codeBoxView.position)
    }

    func codeBoxViewDidDelete (_ codeBoxView: InputCodeBoxView, goToPrevious: Bool) {
        self.delegate?.codeView(self, didChange: codeBoxView.text ?? "", for: codeBoxView.position)
        if goToPrevious, let previousPasswordInputBoxView = self.inputCodeBoxArray.previousRequested(from: codeBoxView.position) {
            previousPasswordInputBoxView.becomeFirstResponder()
        }
    }
}

extension Array where Element == InputCodeBoxView {
    func nextEmptyRequested(from position: NSInteger) -> InputCodeBoxView? {
        guard position > 0, position < self.count else { return nil }
        return self.first { $0.requested == true && $0.position >= position && $0.text?.count == 0 }
    }

    func previousRequested(from position: NSInteger) -> InputCodeBoxView? {
        guard position > 0, position <= self.count else { return nil }
        return self.last { $0.requested == true && $0.position < position }
    }

    func firstEmptyRequested() -> InputCodeBoxView? {
        return self.first { $0.requested == true && $0.text?.count == 0 }
    }

    func isAnyFirstResponder() -> InputCodeBoxView? {
        return self.first { $0.isFirstResponder }
    }

    func fulfilledBoxViews() -> [InputCodeBoxView]? {
        return self.filter { return $0.requested == true && ($0.text ?? "").count > 0 }
    }

    func fulfilledText() -> String? {
        guard let fullfilledInputBoxArray = self.fulfilledBoxViews() else { return nil }
        return fullfilledInputBoxArray.reduce("", { result, inputBox in
            return result + (inputBox.text ?? "")
        })
    }

    func fulfilledCount() -> Int {
        guard let fulfilledInputBoxArray = self.fulfilledBoxViews() else { return 0 }
        return fulfilledInputBoxArray.count
    }

    func requestedCount() -> Int {
        return self.filter { $0.requested == true }.count
    }
    
    func reset() {
        guard let fullfilledInputBoxArray = self.fulfilledBoxViews() else { return }
        fullfilledInputBoxArray.map { $0.text = "" }
    }
}
