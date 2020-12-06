
import UIKit
import RealmSwift
protocol ReloadCollection {
    func reloadCollection()
}
class CircleCell: BaseCell {
    var color = UIColor.clear
    var image = ""
    var baseView = RoundView()
    var imgView = UIImageView()
    var type = ""
    var delegate: ReloadCollection?
//    var imgGest = UITapGestureRecognizer()
//    var colorGest = UITapGestureRecognizer()
    override func setUpViews() {
        super.setUpViews()
        self.isUserInteractionEnabled = true
        baseView.isUserInteractionEnabled = true
        imgView.isUserInteractionEnabled = true
    }
    func removeBase() {
        imgView.removeFromSuperview()
        baseView.clearConstraints()
        baseView.removeFromSuperview()
    }

    func configureUI(){
        self.addSubview(baseView)
        baseView.addSubview(imgView)
        if image != "" {
            baseView.backgroundColor = .clear
            baseView.layer.borderColor = UIColor.clear.cgColor
//            baseView.removeGestureRecognizer(colorGest)
            baseView.width(self.frame.width)
            baseView.height(self.frame.height)
            imgView.image = UIImage(named: image)
//             imgGest = UITapGestureRecognizer(target: self, action: #selector(tappedImage))
            imgView.width(self.frame.width)
            imgView.height(self.frame.height)
            imgView.isUserInteractionEnabled = true
//            imgView.addGestureRecognizer(imgGest)
            
        } else if color != UIColor.clear {
            baseView.width(self.frame.width * 0.80)
            baseView.height(self.frame.height * 0.80)
            baseView.backgroundColor = color
//            colorGest = UITapGestureRecognizer(target: self, action: #selector(tappedColor))
//            baseView.addGestureRecognizer(colorGest)
        }
    }
    
     func tappedImage() {
        baseView.backgroundColor = blue
    }
    func resetImage() {
        baseView.backgroundColor = .clear
    }
    
  func tappedColor() {
        baseView.layer.borderWidth = 5
        baseView.layer.borderColor = color.modified(withAdditionalHue: 0, additionalSaturation: 0.50, additionalBrightness: -0.25).cgColor
    }
    func resetColor() {
        baseView.layer.borderColor = UIColor.clear.cgColor
    }
}
