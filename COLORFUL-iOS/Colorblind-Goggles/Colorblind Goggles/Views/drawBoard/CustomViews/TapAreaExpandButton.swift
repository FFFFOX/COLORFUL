import UIKit

// https://qiita.com/KikurageChan/items/9d0e3ba82e6492e02d12

@IBDesignable class TapAreaExpandButton: UIButton {

    @IBInspectable var dotLineColor: UIColor = .black

    @IBInspectable var top: CGFloat {
        get { return expandEdgeInsets.top }
        set { expandEdgeInsets.top = newValue }
    }
    @IBInspectable var left: CGFloat {
        get { return expandEdgeInsets.left }
        set { expandEdgeInsets.left = newValue }
    }
    @IBInspectable var bottom: CGFloat {
        get { return expandEdgeInsets.bottom }
        set { expandEdgeInsets.bottom = newValue }
    }
    @IBInspectable var right: CGFloat {
        get { return expandEdgeInsets.right }
        set { expandEdgeInsets.right = newValue }
    }

    var expandEdgeInsets = UIEdgeInsets.zero

    var expandedBounds: CGRect {
        return CGRect(x: bounds.origin.x - expandEdgeInsets.left,
                      y: bounds.origin.y - expandEdgeInsets.top,
                      width: bounds.size.width + expandEdgeInsets.left + expandEdgeInsets.right,
                      height: bounds.size.height + expandEdgeInsets.top + expandEdgeInsets.bottom)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return expandedBounds.contains(point)
    }
}
