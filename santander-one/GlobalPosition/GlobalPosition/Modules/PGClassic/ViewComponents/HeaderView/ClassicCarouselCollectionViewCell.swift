import UIKit

class ClassicCarouselCollectionViewCell: UICollectionViewCell {
    
    private var action: ((PGActionType) -> Void)?
    
    func setViewModel(_ viewModel: CarouselClassicItemViewModelType) {
        contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        let view = viewModel.view
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.action = viewModel.action
    }
    
}
