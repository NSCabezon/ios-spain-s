import UIKit

class PlaceholderView: UIView {

    var placeholder: UIImage?
    var topInset: CGFloat?
    
    var yOrigin: CGFloat = 0
    var placeholders: [Placeholder]?
    
    convenience init(size: CGSize, placeholderImages: [Placeholder], topInset: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height - topInset))
        self.placeholders = placeholderImages
        self.topInset = topInset
        drawPlaceholders()
        
    }
    
    func setPlaceholder(placeholderImages: [Placeholder], topInset: CGFloat) {
        self.placeholders = placeholderImages
        self.topInset = topInset
        drawPlaceholders()
    }
    
    func calculateSize(placeholder: UIImage) -> CGSize {
        let newWidth = self.frame.width
        let ratio = placeholder.size.height / placeholder.size.width
        let newHeight = newWidth * ratio
        let newSize = CGSize(width: newWidth, height: newHeight)
        return newSize
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func drawPlaceholders() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        if let placeholders = placeholders { 
            for placeholder in placeholders {
                if let imageName = placeholder.placeholderImage, let image = Assets.image(named: imageName) {
                    let placeholderSize = calculateSize(placeholder: image)
                    resizePlaceholder(placeholder, placeholderSize)
                    yOrigin += placeholderSize.height + 20.0
                }
                
            }
        }
        
        self.placeholder = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        addPlaceholder()
        
    }
    
    private func resizePlaceholder(_ placeholder: Placeholder, _ size: CGSize) {
        if let imageName = placeholder.placeholderImage, let image = Assets.image(named: imageName) {
            image.draw(in: CGRect(x: placeholder.insets!, y: yOrigin, width: size.width - placeholder.insets!*2, height: size.height))
        }
    }
    
    private func addPlaceholder() {
        if let placeHolderImage = placeholder {
            self.backgroundColor = UIColor(patternImage: placeHolderImage)
        }
    }

}
