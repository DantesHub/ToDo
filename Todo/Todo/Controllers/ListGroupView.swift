//import UIKit
//import TinyConstraints
//class ListGroupView: UIView {
//
//    let cellId = "listGroupId"
//    let listGroupTable = UITableView()
//    required init?(coder aDecoder: NSCoder) {
//          super.init(coder: aDecoder)
//      }
//    override init(frame: CGRect, text: String) {
//          super.init(frame: frame)
//          configureUI()
//    }
//
//    func configureUI() {
//        let label = UILabel()
//        self.addSubview(label)
//        label.centerY(to: self)
//        label.font = UIFont(name: "OpenSans-Regular", size: 20)
//        label.textColor = .blue
//        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
//        let arw = UIImageView(image: UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 20, height: 20)))
//        self.addSubview(arw)
//        arw.image = arw.image?.rotate(radians: .pi/2)
//        arw.centerY(to: self)
//        arw.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
//        var tapGestureRecognizer: UITapGestureRecognizer
//        label.text = "Groups"
//        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionClosure))
//        arw.isUserInteractionEnabled = true
//        arw.addGestureRecognizer(tapGestureRecognizer)
//    }
//    
// 
//       
//}
