import UIKit
import UI

extension UINavigationItem {
    func setImageInTitle(_ image: UIImage, padding: CGFloat = 0, resize factor: CGFloat = 1.0) {
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        
        let container = UIView()
        container.frame.resize(to: imageView.frame.size)
        container.frame.resize(factor: 1)
        container.addSubview(imageView)
        
        let size = container.frame.size
        imageView.frame.resize(to: CGSize(width: size.width * factor, height: size.height * factor))
        imageView.frame.move(to: CGPoint(x: (container.frame.width - imageView.frame.width) / 2, y: padding))
        
        titleView = container
    }
    
    func setImageInTitle(withTitle title: LocalizedStylableText, view: UIView, separation: CGFloat = 0.0, viewWidth: CGFloat? = nil) {
        view.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        view.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        if let viewWidth = viewWidth {
            view.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
        }

        let label = UILabel()
        label.textColor = .santanderRed
        label.applyStyle(LabelStylist(textColor: .santanderRed, font: .santanderHeadlineBold(size: 16.0)))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.set(localizedStylableText: title)
        container.addSubview(label)
        label.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor).isActive = true
        label.bottomAnchor.constraint(greaterThanOrEqualTo: container.bottomAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.leftAnchor, constant: -separation).isActive = true
        label.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.baselineAdjustment = .alignCenters
        if viewWidth == nil {
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .vertical)
        }
        container.layoutIfNeeded()
        if #available(iOS 11.0, *) {
            // Nothing to do here
        } else {
            container.translatesAutoresizingMaskIntoConstraints = true
        }
        titleView = container
    }
    
    func setImageInTitle(withTitle title: LocalizedStylableText, image: UIImage, separation: CGFloat = 0.0, imageWidth: CGFloat? = nil) {        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        setImageInTitle(withTitle: title, view: imageView, separation: separation, viewWidth: imageWidth)
    }

    func setInfoTitle(_ title: LocalizedStylableText, button: UIButton, imageWidth: CGFloat? = nil) {
        let image = Assets.image(named: "icnInfoRedLight")
        button.setImage(image, for: .normal)
        button.isAccessibilityElement = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 21).isActive = true
        button.heightAnchor.constraint(equalToConstant: 21).isActive = true
        setImageInTitle(withTitle: title, view: button, separation: 8.0, viewWidth: imageWidth)
    }
    
    private func resizeImage(image: UIImage, scaledToSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(scaledToSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledToSize.width, height: scaledToSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
