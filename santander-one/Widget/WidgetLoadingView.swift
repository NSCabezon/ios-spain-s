import UIKit

class WidgetLoading: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        let images = imagesPack(name: "loader_widget_\(indexLabel)", range: 1...47, format: "%02d").compactMap { $0?.resize(factor: 2.0) }.map { $0! }
        animationImages = images
        startAnimating()
        backgroundColor = UIColor.clear
    }
    
    private let indexLabel = "[index]"
    private func imagesPack(name: String, range: CountableClosedRange<Int>, format: String? = nil) -> [UIImage?] {
        var images = [UIImage?]()
        for i in range {
            let revision = format == nil ? name.replace(indexLabel, String(i)) : name.replace(indexLabel, String.init(format: format!, i))
            images += [UIImage(named: revision)]
        }
        return images
    }

}
