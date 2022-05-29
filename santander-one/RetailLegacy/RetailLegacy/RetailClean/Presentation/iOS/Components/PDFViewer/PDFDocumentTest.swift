import CoreGraphics
import UIKit

public struct DocumentPDF {
    
    let pageCount: Int
    let fileURL: URL?
    let fileData: Data
    let coreDocument: CGPDFDocument
    let images = NSCache<NSNumber, UIImage>()
    let password: String?
    
    init?(url: URL, password: String? = nil) {
        guard let fileData = try? Data(contentsOf: url) else { return nil }
        
        self.init(fileData: fileData, fileURL: url, password: password)
    }
    
    init?(fileData: Data, password: String? = nil) {
        self.init(fileData: fileData, fileURL: nil, password: password)
    }
    
    private init?(fileData: Data, fileURL: URL?, password: String?) {
        guard let provider = CGDataProvider(data: fileData as CFData) else { return nil }
        guard let coreDocument = CGPDFDocument(provider) else { return nil }
        
        self.fileData = fileData
        self.fileURL = fileURL
        
        if let password = password {
            
            if coreDocument.isEncrypted && !coreDocument.unlockWithPassword("") {
                self.password = password
            } else {
                self.password = nil
            }
        } else {
            self.password = nil
        }
        
        self.coreDocument = coreDocument
        self.pageCount = coreDocument.numberOfPages
        self.loadPages()
    }
    
    func loadPages() {
        DispatchQueue.global(qos: .background).async {
            for pageNumber in 1...self.pageCount {
                self.imageFromPDFPage(at: pageNumber, callback: { backgroundImage in
                    guard let backgroundImage = backgroundImage else { return }
                    self.images.setObject(backgroundImage, forKey: NSNumber(value: pageNumber))
                })
            }
        }
    }
    
    func allPageImages(callback: ([UIImage]) -> Void) {
        var images = [UIImage]()
        var pagesCompleted = 0
        for pageNumber in 0..<pageCount {
            pdfPageImage(at: pageNumber+1, callback: { (image) in
                if let image = image {
                    images.append(image)
                }
                pagesCompleted += 1
                if pagesCompleted == pageCount {
                    callback(images)
                }
            })
        }
    }
    
    func pdfPageImage(at pageNumber: Int, callback: (UIImage?) -> Void) {
        if let image = images.object(forKey: NSNumber(value: pageNumber)) {
            callback(image)
        } else {
            imageFromPDFPage(at: pageNumber, callback: { image in
                guard let image = image else {
                    callback(nil)
                    return
                }
                
                images.setObject(image, forKey: NSNumber(value: pageNumber))
                callback(image)
            })
        }
    }
    
    private func imageFromPDFPage(at pageNumber: Int, callback: (UIImage?) -> Void) {
        guard let page = coreDocument.page(at: pageNumber) else {
            callback(nil)
            return
        }
        
        let originalPageRect = page.originalPageRect
        
        let scalingConstant: CGFloat = 240
        let pdfScale = min(scalingConstant/originalPageRect.width, scalingConstant/originalPageRect.height)
        let scaledPageSize = CGSize(width: originalPageRect.width * pdfScale, height: originalPageRect.height * pdfScale)
        let scaledPageRect = CGRect(origin: originalPageRect.origin, size: scaledPageSize)
        
        UIGraphicsBeginImageContextWithOptions(scaledPageSize, true, 1)
        guard let context = UIGraphicsGetCurrentContext() else {
            callback(nil)
            return
        }
        
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fill(scaledPageRect)
        
        context.saveGState()
        
        let rotationAngle: CGFloat
        switch page.rotationAngle {
        case 90:
            rotationAngle = 270
            context.translateBy(x: scaledPageSize.width, y: scaledPageSize.height)
        case 180:
            rotationAngle = 180
            context.translateBy(x: 0, y: scaledPageSize.height)
        case 270:
            rotationAngle = 90
            context.translateBy(x: scaledPageSize.width, y: scaledPageSize.height)
        default:
            rotationAngle = 0
            context.translateBy(x: 0, y: scaledPageSize.height)
        }
        
        context.scaleBy(x: 1, y: -1)
        context.rotate(by: rotationAngle.degreesToRadians)
        context.scaleBy(x: pdfScale, y: pdfScale)
        context.drawPDFPage(page)
        context.restoreGState()
        
        defer { UIGraphicsEndImageContext() }
        guard let backgroundImage = UIGraphicsGetImageFromCurrentImageContext() else {
            callback(nil)
            return
        }
        
        callback(backgroundImage)
    }
}

extension CGPDFPage {
    
    var originalPageRect: CGRect {
        switch rotationAngle {
        case 90, 270:
            let originalRect = getBoxRect(.mediaBox)
            let rotatedSize = CGSize(width: originalRect.height, height: originalRect.width)
            return CGRect(origin: originalRect.origin, size: rotatedSize)
        default:
            return getBoxRect(.mediaBox)
        }
    }
}
