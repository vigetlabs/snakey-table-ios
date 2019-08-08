import UIKit

let ANIM_DURATION: Double = 0.25

class SnakeyTableCell: UITableViewCell {

    var xPadding: CGFloat = 36.0
    var path: UIBezierPath!
    let strokeColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
    lazy var shapeLayer: CAShapeLayer = {
        let sLayer = CAShapeLayer()
        sLayer.fillColor = UIColor.clear.cgColor
        sLayer.strokeColor = strokeColor
        sLayer.lineWidth = 1.0
        sLayer.strokeEnd = 1.0

        layer.addSublayer(sLayer)
        return sLayer
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        path = UIBezierPath()
        updateShapeLayer()
    }

    private func updateShapeLayer() {
        shapeLayer.path = path.cgPath
    }

    func render(position: Int, total: Int) {
        let isFirst = position == 0

        // These are counted with offsets to account for zero-based numbering
        let isEven = (position + 1) % 2 == 0
        let isLast = position + 1 == total
        let isSecondLast = position + 2 == total

        // The last cell should not draw anything.
        if isLast {
            return
        }

        // Each cell will start with its own fresh, discrete path
        path = UIBezierPath()

        if isFirst {
            drawFirstPath(path, total: total)
        } else if isEven {
            drawEvenPath(path, isSecondLast: isSecondLast)
        } else {
            drawOddPath(path, isSecondLast: isSecondLast)
        }

        updateShapeLayer()
    }

    /// Draws a line from the lower left to lower right of the first cell.
    private func drawFirstPath(_ path: UIBezierPath, total: Int) {
        let width = frame.size.width
        let height = frame.size.height
        let padding = total == 2 ? 0.0 : xPadding

        path.move(to: CGPoint(x: 0.0, y: height))
        path.addLine(to: CGPoint(x: width - padding, y: height))
    }

    /// Right tip of the cell, which arcs around and travels to the lower left edge of the cell
    private func drawEvenPath(_ path: UIBezierPath, isSecondLast: Bool) {
        let centerY = frame.size.height / 2
        let height = frame.size.height
        let width = frame.size.width

        // The radius of each arc is equal to half the cell height
        let arcRadius = frame.size.height / 2
        let arcCenter = CGPoint(x: width - xPadding, y: centerY)

        path.addArc(
            withCenter: arcCenter,
            radius: arcRadius,
            startAngle: 3 / 2 * .pi,
            endAngle: .pi / 2,
            clockwise: true
        )

        path.addLine(to: CGPoint(x: isSecondLast ? 0.0 : xPadding, y: height))
    }

    /// This is the left end of the cell, which arcs around and travels to the right edge
    private func drawOddPath(_ path: UIBezierPath, isSecondLast: Bool) {
        let width = frame.size.width
        let height = frame.size.height
        let centerY = frame.size.height / 2

        // The radius of each arc is equal to half the cell height
        let arcRadius = frame.size.height / 2
        let arcCenter = CGPoint(x: xPadding, y: centerY)

        path.addArc(
            withCenter: arcCenter,
            radius: arcRadius,
            startAngle: 3 / 2 * .pi,
            endAngle: .pi / 2,
            clockwise: false
        )

        path.addLine(to: CGPoint(x: isSecondLast ? width : (width - xPadding), y: height))
    }

    func animate(position: Int) {
        // This is set to 0, so nothing in the path will be drawn initially.
        shapeLayer.strokeEnd = 0.0

        // The stagger value should start with a min. of 1, even if array index is 0.
        let stagger = ANIM_DURATION * Double(position + 1)

        DispatchQueue.main.asyncAfter(deadline: .now() + stagger) {
            self.shapeLayer.strokeEnd = 1.0

            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = ANIM_DURATION

            self.shapeLayer.add(animation, forKey: nil)
        }
    }

}
