import Foundation
import UIKit

extension UIView {
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }
    
    public func roundCorners(radius: CGFloat = cornerRadius) {
        layer.cornerRadius = radius
    }
    
    public func dropShadow(radius: CGFloat = cornerRadius) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = false
    }
    
    public func addGradient(radius: CGFloat = cornerRadius, color1: CGColor, color2: CGColor) {
        let gradient = CAGradientLayer()
        gradient.colors = [color1, color2]
        gradient.opacity = 0.6
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = bounds
        gradient.cornerRadius = radius
        layer.insertSublayer(gradient, at: 0)
    }
}
