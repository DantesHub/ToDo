
import UIKit
import TinyConstraints
import RealmSwift

struct ListCell {
    var selected = false
    var name = ""
}

var listDictionary = [ListCell]()
class AddListToGroupTableView: UIView, CustomCellUpdater {
    //MARK: - Views + Properties
    var results: Results<ListObject>!
    var isSearchBarEmpty: Bool {
      return searchBar.text?.isEmpty ?? true
    }
    var reloadDelegate: ReloadDelegate?
    var filteredLists = [ListCell]()
    var checked = [Bool]()
     let tableView = UITableView()
    var searchBar: UISearchBar! = UISearchBar()
    var isFiltering: Bool = false

     //MARK: - Inita=
    override init(frame: CGRect) {
        super.init(frame: frame)
        overrideUserInterfaceStyle = .light
        setUpListDictionary()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       // Here write down you logic to dismiss controller
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.tableView.transform = CGAffineTransform(translationX: 0, y: 1200)
        }) { (_) in self.removeFromSuperview()}
    }
    
    func setUpViews() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListToGroupCell.self, forCellReuseIdentifier: K.listGroupCell)
        tableView.layer.cornerRadius = 25
        tableView.edgesToSuperview(insets: TinyEdgeInsets(top: -150, left: 50, bottom: 550
            , right: 50))
//        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.tableView.transform = CGAffineTransform(translationX: 0, y: 325)
                }) { (_) in }
        tableView.rowHeight = 50
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        searchBar.placeholder = "Search For List"
        searchBar.sizeToFit()
        searchBar.delegate = self
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = UIFont(name: "OpenSans-Regular", size: 12)
        //SearchBar Placeholder
        let textFieldInsideUISearchBarLabel = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideUISearchBarLabel?.font = UIFont(name: "OpenSans-Regular", size: 12)
        tableView.tableHeaderView = searchBar
    }
    func setUpListDictionary() {
        listDictionary = []
        results = uiRealm.objects(ListObject.self)
        for result  in results {
            var listCell = ListCell()
            listCell.name = result.name
            if (selectedGroup?.lists.contains(where: {$0.name == result.name}) == true) {
                listCell.selected = true
            } else {
                listCell.selected = false
            }
            listDictionary.append(listCell)
        }
        setUpViews()
    }
    
    
    func filterContentForSearchText(_ searchText: String) {
      filteredLists = listDictionary.filter { (list: ListCell) -> Bool in
        return list.name.lowercased().contains(searchText.lowercased())
      }
      tableView.reloadData()
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
    
    func updateRealm(list: ListCell) {
        for result  in results {
                do {
                    if result.name == list.name {
                        print("over here")
                        try uiRealm.write {
                            if list.selected == true {
                                print("already selected")//remove list
                                for (index,listInGroup) in selectedGroup!.lists.enumerated() {
                                    if result.name == listInGroup.name {
                                        selectedGroup?.lists.remove(at: index)
                                    }
                                }
                            } else { //add list
                                print(selectedGroup?.name ?? "baka")
                                selectedGroup?.lists.append(result)
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
        setUpListDictionary()
        tableView.reloadData()
        reloadDelegate?.reloadTableView()
    }
}

extension AddListToGroupTableView: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          if isFiltering {
          return filteredLists.count
        }
        return listDictionary.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listCell: ListCell
        if isFiltering {
            listCell = filteredLists[indexPath.row]
        } else {
            listCell = listDictionary[indexPath.row]
        }
        let cell = ListToGroupCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: K.listGroupCell, title: listCell.name)
        cell.delegate = self
        cell.imgView.image = listCell.selected ? UIImage(named: "star")?.resize(targetSize: CGSize(width: 25, height: 25)) : UIImage(named: "plus")?.resize(targetSize: CGSize(width: 25, height: 25))
        return cell
    }
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) {
        if listDictionary[indexPath.row].selected == false {
            cell.imageView!.image = UIImage(named: "plus")?.resize(targetSize: CGSize(width: 25, height: 25))
        } else {
            cell.imageView!.image = UIImage(named: "star")?.resize(targetSize: CGSize(width: 25, height: 25))
        }
                updateRealm(list: listDictionary[indexPath.row])
       }
    
   }

   func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
       if let cell = tableView.cellForRow(at: indexPath) {
           cell.accessoryType = .none
       }
   }

}

extension AddListToGroupTableView: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       filterContentForSearchText(searchBar.text!)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isFiltering = !isSearchBarEmpty
        if isFiltering == false {
            tableView.reloadData()
        } else {
            filterContentForSearchText(searchBar.text!)
            tableView.reloadData()
        }
    }
    

}
