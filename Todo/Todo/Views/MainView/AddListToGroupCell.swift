import UIKit
import TinyConstraints
import RealmSwift

var selectedColor = "red"
var tagTitle = ""
class ListToGroupCell: UITableViewCell {
    //MARK: - Properties
    weak var delegate: CustomCellUpdater?
    var results: Results<ListObject>!
    var title: String = ""
    var titleLabel = UILabel()
    var imgView = UIImageView()
     //MARK: - Init
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, title: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.title = title
        configureCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper Functinos
    func configureCellUI() {
        self.selectionStyle = .none
        titleLabel.font = UIFont(name: "OpenSans-Regular", size: 15)
        titleLabel.text = title
        titleLabel.sizeToFit()
        contentView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.centerY(to: contentView)
        contentView.addSubview(imgView)
        imgView.centerY(to: contentView)
        imgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
    }
}





protocol CustomCellUpdater: class {
    func updateTableView()
}
