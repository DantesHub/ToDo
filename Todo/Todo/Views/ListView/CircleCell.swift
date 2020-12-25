
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
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                if type == "Photo" {
                    tappedImage()
                } else if type == "Background Color"{
                    tappedColor()
                } else {
                    tappedColor()
                }
            } else {
                if type == "Photo" {
                    resetImage()
                } else if type == "Background Color"{
                    resetColor()
                } else {
                    resetColor()
                }
            }
        }
    }
    override func setUpViews() {
        super.setUpViews()
        self.isUserInteractionEnabled = true
        baseView.isUserInteractionEnabled = true
        imgView.isUserInteractionEnabled = true
    }
    func removeBase() {
        baseView.clearConstraints()
        baseView.removeFromSuperview()
    }

    func configureUI(){
        self.addSubview(baseView)
        baseView.addSubview(imgView)
        if image != "" {
            baseView.backgroundColor = .clear
            baseView.layer.borderColor = UIColor.clear.cgColor
            baseView.width(self.frame.width)
            baseView.height(self.frame.height)
            imgView.image = UIImage(named: image)
            imgView.width(self.frame.width)
            imgView.height(self.frame.height)
            imgView.isUserInteractionEnabled = true
            
        } else if color != UIColor.clear {
            baseView.backgroundColor = color
            if color == .white {
                baseView.layer.borderWidth = 2
                baseView.layer.borderColor = UIColor.gray.cgColor
            }
            
            baseView.width(self.frame.width * 0.80)
            baseView.height(self.frame.height * 0.80)
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
        if color == .white {
            baseView.layer.borderWidth = 2
            baseView.layer.borderColor = UIColor.gray.cgColor
        } else {
            baseView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
