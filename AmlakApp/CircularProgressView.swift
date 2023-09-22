import UIKit

class CircularProgressView: UIView {

    private var progressLayer = CAShapeLayer()
    private var percentageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCircularProgress()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCircularProgress()
    }

    private func setupCircularProgress() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 20 // Adjust this value for the thickness of the circle
        
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
//        let endAngle = -CGFloat.pi / 2 + CGFloat(progress) * 2 * CGFloat.pi
//        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: endAngle, clockwise: true)

        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.blue.cgColor // Change the color as desired
        progressLayer.lineWidth = 20 // Adjust this value for the thickness of the circle
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        
        // Create and configure the percentage label
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = center
        percentageLabel.textAlignment = .center
        percentageLabel.textColor = UIColor.black // Change the color as desired
        percentageLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        addSubview(percentageLabel)
        layer.addSublayer(progressLayer)
    }
    
    func setProgress(_ progress: Float) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 20 // Adjust this value for the thickness of the circle
        
        let endAngle = -CGFloat.pi / 2 + CGFloat(progress) * 2 * CGFloat.pi
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: endAngle, clockwise: true)

        progressLayer.path = circularPath.cgPath
        progressLayer.strokeEnd = CGFloat(progress)
        
        // Update the percentage label
        let percentage = Int(progress * 100)
        percentageLabel.text = "\(percentage)%"
    }
}
