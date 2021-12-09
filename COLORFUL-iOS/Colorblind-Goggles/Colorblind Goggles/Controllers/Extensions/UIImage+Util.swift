import Foundation
import UIKit

extension UIImage {

    func composite(image: UIImage) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)

        draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
}
