//TODO: Make gradient behind the date - height: 30px; background: linear-gradient(180deg, rgba(26, 27, 34, 0) 0%, rgba(26, 27, 34, 0.2) 53.93%);

import UIKit

class GradientView: UIView {
    
    private let startColor = UIColor(red: 26/255.0, green: 27/255.0, blue: 34/255.0, alpha: 0)
    private let endColor = UIColor(red: 26/255.0, green: 27/255.0, blue: 34/255.0, alpha: 0.2)
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        roundCorners(corners: [.bottomLeft, .bottomRight], radius: 16.0)
    }
    
    private func setUpGradient() {
        self.layer.addSublayer(gradientLayer)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5393)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
}

extension GradientView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
