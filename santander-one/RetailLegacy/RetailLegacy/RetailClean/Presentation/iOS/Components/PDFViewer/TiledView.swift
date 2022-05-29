import UIKit
import QuartzCore

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

class TiledView: UIView {
    
    private var leftPdfPage: CGPDFPage?
    
    private let myScale: CGFloat

    init(frame: CGRect, scale: CGFloat, newPage: CGPDFPage) {
        myScale = scale
        leftPdfPage = newPage
        super.init(frame: frame)
        
        let tiledLayer = self.layer as? CATiledLayer
        tiledLayer?.levelsOfDetail = 16
        tiledLayer?.levelsOfDetailBias = 15
        tiledLayer?.tileSize = CGSize(width: 1024, height: 1024)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        return CATiledLayer.self
    }
    
    override func draw(_ layer: CALayer, in con: CGContext) {
        guard let leftPdfPage = leftPdfPage else { return }
        
        con.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        con.fill(layer.bounds)
        con.saveGState()
        
        let rotationAngle: CGFloat
        switch leftPdfPage.rotationAngle {
        case 90:
            rotationAngle = 270
            con.translateBy(x: layer.bounds.width, y: layer.bounds.height)
        case 180:
            rotationAngle = 180
            con.translateBy(x: 0, y: layer.bounds.height)
        case 270:
            rotationAngle = 90
            con.translateBy(x: layer.bounds.width, y: layer.bounds.height)
        default:
            rotationAngle = 0
            con.translateBy(x: 0, y: layer.bounds.height)
        }
        
        con.scaleBy(x: 1, y: -1)
        con.rotate(by: rotationAngle.degreesToRadians)
        con.scaleBy(x: myScale, y: myScale)
        con.drawPDFPage(leftPdfPage)
        con.restoreGState()
    }
    
    deinit {
        leftPdfPage = nil
        layer.contents = nil
        layer.delegate = nil
        layer.removeFromSuperlayer()
    }
}
