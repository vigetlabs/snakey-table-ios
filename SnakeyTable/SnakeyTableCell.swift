import UIKit

let SNAKEY_CELL_ANIM_DURATION: Double = 0.25

class SnakeyTableCell: UITableViewCell {

    var xPadding: CGFloat = 36.0
    var path: UIBezierPath!
    var shapeLayer = CAShapeLayer()
    let strokeColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        path = UIBezierPath()
        drawShapeLayer()
    }

    func render(_ index: Int, last: Int) {
        let isFirst = index == 0

        // These are counted with offsets to account for zero-based numbering
        let isEven = (index + 1) % 2 == 0
        let isLast = index + 1 == last
        let isSecondLast = index + 2 == last

        // The last cell should not draw anything.
        if isLast {
            return
        }

        // Each cell will start with its own fresh, discrete path
        path = UIBezierPath()

        if isFirst {
            drawFirstPath(path, last: last)
        } else if isEven {
            drawEvenPath(path, isSecondLast: isSecondLast)
        } else {
            drawOddPath(path, isSecondLast: isSecondLast)
        }

        drawShapeLayer()
    }

    /// Draws a line from the lower left to lower right of the first cell.
    private func drawFirstPath(_ path: UIBezierPath, last: Int) {
        let width = frame.size.width
        let height = frame.size.height
        let padding = last == 2 ? 0.0 : xPadding

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
            startAngle: -.pi / 2,
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
            startAngle: -.pi / 2,
            endAngle: .pi / 2,
            clockwise: false
        )

        path.addLine(to: CGPoint(x: isSecondLast ? width : (width - xPadding), y: height))
    }

    private func drawShapeLayer() {
        // We must remove the layer first to avoid stacking
        shapeLayer.removeFromSuperlayer()

        shapeLayer = CAShapeLayer()
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.strokeEnd = 1.0

        layer.addSublayer(shapeLayer)
    }

    func animate(position: Int) {
        // This is set to 0, so nothing in the path will be drawn initially.
        shapeLayer.strokeEnd = 0.0

        // The stagger value should start with a min. of 1, even if array index is 0.
        let stagger = SNAKEY_CELL_ANIM_DURATION * Double(position + 1)

        DispatchQueue.main.asyncAfter(deadline: .now() + stagger) {
            self.shapeLayer.strokeEnd = 1.0

            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = SNAKEY_CELL_ANIM_DURATION

            self.shapeLayer.add(animation, forKey: nil)
        }
    }

}
