import UIKit
import TinyConstraints

class BoxOption: UIView {
    let label = UILabel()
    var image = ""
    let imageView = UIImageView()
    //initWithFrame to init view from code
    override init(frame: CGRect) {
       super.init(frame: frame)
        setupView()
     }
     
     //initWithCode to init view from xib or storyboard
     required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       setupView()
   
     }
     
     //common func to init our view
      func setupView() {
        self.addSubview(label)
        label.font = UIFont(name: "OpenSans-Regular", size: 14)
        label.textColor = .gray
        
        label.centerX(to: self)
        label.bottom(to: self, offset: -15)
     }
    
    func createImage() {
        self.addSubview(imageView)
        if image == "Delete List" {
            imageView.image = UIImage(named: image)?.resize(targetSize: CGSize(width: 28, height: 28)).withTintColor(.gray)
        } else if image == "move" {
            imageView.image = UIImage(named: image)?.resize(targetSize: CGSize(width: 40, height: 40)).withTintColor(.gray)
            imageView.image = imageView.image?.imageWithInsets(insets: UIEdgeInsets(top: 0, left: 0, bottom: -10, right: 0))
        } else {
            imageView.image = UIImage(named: image)?.resize(targetSize: CGSize(width: 21, height: 21)).withTintColor(.gray)
        }
        imageView.isUserInteractionEnabled = true
        imageView.centerX(to: self)
        imageView.bottomToTop(of: label, offset: -15)
    }
}
