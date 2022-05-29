public protocol StackviewDelegate: AnyObject {
    func didChangeBounds(for stackview: UIStackView)
}

public class Stackview: UIStackView {
    public weak var delegate: StackviewDelegate?
    override public var bounds: CGRect {
        didSet {
            delegate?.didChangeBounds(for: self)
        }
    }
}
