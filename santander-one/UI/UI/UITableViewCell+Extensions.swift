import UIKit

extension UITableViewCell {
    public func setReorderControlImage(_ image: UIImage?) {
        guard let image = image else { return }
        let reorderView = self.subviews.first(where: { $0.description.contains("Reorder") })
        let reorderViewImageView = reorderView?.subviews.first(where: { $0 is UIImageView }) as? UIImageView
        reorderViewImageView?.image = image
        reorderViewImageView?.contentMode = .center
        reorderViewImageView?.frame.size.width = self.bounds.height
        reorderViewImageView?.frame.size.height = self.bounds.height
    }
    
    public func setReorderControlAlignment(_ alignment: ContentMode, correction: CGFloat = 0.0) {
        let reorderView = self.subviews.first(where: { $0.description.contains("Reorder") })
        let reorderViewImageView = reorderView?.subviews.first(where: { $0 is UIImageView })
        reorderViewImageView?.contentMode = alignment
        reorderViewImageView?.frame.size.width = self.bounds.height - correction
    }
}
