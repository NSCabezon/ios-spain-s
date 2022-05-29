import UIKit
import RetailLegacy

class WidgetTitleRowView: UIView {

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func setTitle(_ title: String) {
        setupViews()
        titleLabel.text = title
    }
    
    private func setupViews() {
        titleLabel.textColor = .sanRed
        titleLabel.font = .latoBold(size: 13.0)
        separatorView.backgroundColor = UIColor.sanGreyMedium.withAlphaComponent(0.5)
    }
}

extension WidgetTitleRowView: ViewCreatable {}
