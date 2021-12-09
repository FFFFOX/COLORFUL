import Foundation
import UIKit

extension UIView {

    func getImage() -> UIImage {

        let rect = self.bounds

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 2.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!

        layer.render(in: context)

        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
}
