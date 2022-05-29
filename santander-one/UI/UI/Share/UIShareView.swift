//
//  UIShareView.swift
//  UI
//
//  Created by Laura González on 24/11/2020.
//

open class UIShareView: UIViewController {
    
    public init(nibName: String?, bundleName: Bundle?) {
        super.init(nibName: nibName, bundle: bundleName)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func shareImage(_ view: UIView, onlyWhatsApp: Bool, completion: @escaping () -> Void) {
        let myImage = self.createImage(view)
        let activity = UIActivityViewController(activityItems: [myImage], applicationActivities: nil)
        if onlyWhatsApp {
            if #available(iOS 11.0, *) {
                activity.excludedActivityTypes = [.airDrop, .assignToContact, .addToReadingList, .copyToPasteboard, .mail, .markupAsPDF, .message, .openInIBooks, .postToFacebook, .postToFlickr, .postToTencentWeibo, .postToTwitter, .postToVimeo, .postToWeibo, .saveToCameraRoll, .print]
            } else {
                activity.excludedActivityTypes = [.airDrop, .assignToContact, .addToReadingList, .copyToPasteboard, .mail, .message, .openInIBooks, .postToFacebook, .postToFlickr, .postToTencentWeibo, .postToTwitter, .postToVimeo, .postToWeibo, .saveToCameraRoll, .print]
            }
        }
        activity.completionWithItemsHandler = { (_: UIActivity.ActivityType?, _: Bool, _: [Any]?, _: Error?) in
            completion()
        }
        self.present(activity, animated: true, completion: nil)
    }
}

private extension UIShareView {
    func createImage(_ view: UIView) -> UIImage {
        let imageRenderer = UIGraphicsImageRenderer(bounds: view.bounds)
        if let format = imageRenderer.format as? UIGraphicsImageRendererFormat {
            format.opaque = true
        }
        let image = imageRenderer.image { context in
            return view.layer.render(in: context.cgContext)
        }
        return image
    }
    
    func saveImageToGalery(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
    }
}
