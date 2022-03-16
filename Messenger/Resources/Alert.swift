import Foundation
import UIKit

class Alert {
    
    class func showBasic(title: String, message: String, vc: UIViewController, view: UIView) {
        
        // Blur
        let blurEffect = UIBlurEffect(style: .light)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = view.bounds
        
        // Alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // Magic
            UIView.animate(withDuration: 0.3) {
                blurVisualEffectView.alpha = 0
            } completion: { _ in
                blurVisualEffectView.removeFromSuperview()
            }
        }))
        
        view.addSubview(blurVisualEffectView)
        vc.present(alert, animated: true)
    }
}
