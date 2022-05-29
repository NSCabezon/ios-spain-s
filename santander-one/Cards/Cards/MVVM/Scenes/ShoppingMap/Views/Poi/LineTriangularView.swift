//
//  LineTriangularView.swift
//  Cards
//
//  Created by Hernán Villamil on 23/2/22.
//

final class LineTriangularView: UIView {
    private let lineSize: CGFloat = 1

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let originPoint: CGFloat = rect.size.width / 2
        path.move(to: CGPoint(x: rect.minX +  lineSize, y: rect.minY))
        path.addLine(to: CGPoint(x: originPoint - rect.size.height, y: rect.minY))
        path.addLine(to: CGPoint(x: originPoint, y: rect.maxY))
        path.addLine(to: CGPoint(x: originPoint + rect.size.height, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - lineSize, y: rect.minY))
        UIColor.white.setFill()
        path.fill()
        UIColor.mediumSkyGray.setStroke()
        path.stroke()
    }
}
