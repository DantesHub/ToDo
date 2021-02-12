
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
    let tableView = UITableView.init(frame: .zero, style: .plain)
    var searchBar: UISearchBar! = UISearchBar()
    var isFiltering: Bool = false
    var searching: Bool = false
    var header = UIView()
    let done = UIButton()
    let container = UIView()
    var parentView = MainViewController()
    let title = UILabel()
    let hr = UIView()
     //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        overrideUserInterfaceStyle = .light        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       // Here write down you logic to dismiss controller
       dismissView()
    }

    func setUpViews() {
        self.addSubview(container)
        container.edgesToSuperview(insets: TinyEdgeInsets(top: -150, left: 50, bottom: 550, right: 50))
        container.backgroundColor = .white
        container.layer.cornerRadius = 25
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        container.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
      
        tableView.register(ListToGroupCell.self, forCellReuseIdentifier: K.listGroupCell)
        tableView.layer.cornerRadius = 25
        tableView.edgesToSuperview(insets: TinyEdgeInsets(top: 75, left: 0, bottom: 0
                                                          , right: 0))
//        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.container.transform = CGAffineTransform(translationX: 0, y: 325)
                }) { (_) in }
        tableView.rowHeight = 50
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    func configureUI() {
        setUpListDictionary()
        if self.searching {
            let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideUISearchBar?.font = UIFont(name: "OpenSans-Regular", size: 12)
            //SearchBar Placeholder
            let textFieldInsideUISearchBarLabel = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
            textFieldInsideUISearchBarLabel?.font = UIFont(name: "OpenSans-Regular", size: 12)
            searchBar.placeholder = "Search For List"
            searchBar.delegate = self
            searchBar.overrideUserInterfaceStyle = .light
            container.addSubview(searchBar)
            searchBar.leading(to: self, offset: 50)
            searchBar.trailing(to: self, offset: -50)
            searchBar.clipsToBounds = true
            searchBar.layer.cornerRadius = 25
            searchBar.backgroundColor = .white
            searchBar.topToSuperview(offset: 0)
            searchBar.barTintColor = UIColor.clear
            searchBar.backgroundColor = UIColor.clear
            searchBar.isTranslucent = true
            searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
            searchBar.searchTextField.font = UIFont(name: "OpenSans", size: 20)
            searchBar.tintColor = .white
            searchBar.height(60)
        } else {
            header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            header.overrideUserInterfaceStyle = .light
            container.addSubview(header)
            header.leading(to: self, offset: 50)
            header.trailing(to: self, offset: -50)
            header.backgroundColor = .white
            header.topToSuperview(offset: 0)
            header.layer.cornerRadius = 25
            header.height(60)
            header.addSubview(title)
            header.addSubview(hr)
            header.addSubview(done)
            done.tintColor = .systemBlue
            done.setTitle("Done", for: .normal)
            done.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
            done.setTitleColor(.systemBlue, for: .normal)
            done.titleLabel!.font = UIFont(name: "OpenSans", size: 16)
            done.trailing(to: header, offset: -15)
            done.centerY(to: header)
            hr.leadingToSuperview()
            hr.trailingToSuperview()
            hr.height(1)
            hr.backgroundColor = .darkGray
            hr.topToBottom(of: header)
            title.text = "Add List"
            title.font = UIFont(name: "OpenSans-Bold", size: 18)
            
            title.textColor = .black
            title.center(in: header)
        }
    }
    @objc func dismissView() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.container.transform = CGAffineTransform(translationX: 0, y: 1200)
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        }) { (_) in self.removeFromSuperview()}
    }
    func setUpListDictionary() {
        listDictionary = []
        results = uiRealm.objects(ListObject.self)
        for result  in results {
            var listCell = ListCell()
            listCell.name = result.name
            if !searching {
                if (selectedGroup?.lists.contains(where: {$0.name == result.name}) == true) {
                    listCell.selected = true
                } else {
                    listCell.selected = false
                }
                listDictionary.append(listCell)
            } else {
                listDictionary.append(listCell)
            }
        }
        print("yodle", listDictionary)
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
        let groupResults = uiRealm.objects(ListGroup.self)
        var removedIndex = 0
        let groupPos = uiRealm.objects(GroupPosition.self)
        for result  in results {
                do {
                    if result.name == list.name {
                        try uiRealm.write {
                            if list.selected == true {
                                //remove list
                                for (indx,position) in result.groupPositions.enumerated() {
                                    if position.groupName == selectedGroup!.name {
                                        removedIndex = result.groupPositions[indx].groupPosition
                                        
                                        //selectedGroup lists are not in order which is why we have to loop through it in order
                                        //to find the exact list with exact groupposition and group name
                                        var i = 0
                                        selectedGroup?.lists.forEach{
                                            for poz in $0.groupPositions {
                                                if poz.groupPosition == removedIndex && poz.groupName == selectedGroup?.name {
                                                    selectedGroup?.lists.remove(at: i)
                                                }
                                            }
                                            i += 1
                                        }
                                        //remove from group position list in realm, otherwise it would save all group positions even
                                        //though we removed it from the lists group positions
                                        for (_, groupPosition) in groupPos.enumerated() {
                                            if groupPosition.groupName == selectedGroup?.name && groupPosition.groupPosition == removedIndex {
                                                uiRealm.delete(groupPosition)
                                            }
                                        }
                                    }
                                }
                                  
                                //update group positions that we bigger than the group position that was just deleted.
                                for listInGroup in selectedGroup!.lists {
                                    for groupPosition in listInGroup.groupPositions {
                                        if groupPosition.groupPosition > removedIndex && groupPosition.groupName == selectedGroup!.name {
                                            groupPosition.groupPosition -= 1
                                        }
                                    }
                                }
                                //too handle expand close
                                if (selectedGroup?.lists.count)! > 0 {
                                        selectedGroup?.isExpanded = true
                                    
                                } else {
                                        selectedGroup?.isExpanded = false
    
                                }
                            } else { //add list
                                var count = 0
                                for groupResult in groupResults {
                                    if groupResult.name == selectedGroup?.name {
                                        count = selectedGroup?.lists.count as! Int
                                    }
                                }
                                let groupPosition = GroupPosition()
                                groupPosition.groupName = selectedGroup?.name as! String
                                groupPosition.groupPosition = count
                                result.groupPositions.append(groupPosition)
                                selectedGroup?.lists.append(result)
                                    selectedGroup?.isExpanded = true
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
        if self.searching {
            cell.imgView.image = UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 20, height: 20)).rotate(radians: .pi/2)
        } else {
            cell.imgView.image = listCell.selected ? UIImage(named: "check")?.resize(targetSize: CGSize(width: 25, height: 25)) : UIImage(named: "plus")?.resize(targetSize: CGSize(width: 25, height: 25))
        }
        
        return cell
    }
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.searching {
                dismissView()
                let controller = ListController()
                controller.reloadDelegate = parentView
                controller.creating = false;
                premadeListTapped = false
                let listCell: ListCell
                if isFiltering {
                    listCell = filteredLists[indexPath.row]
                } else {
                    listCell = listDictionary[indexPath.row]
                }
                listTitle = listCell.name
                controller.navigationController?.isNavigationBarHidden = false
                parentView.navigationController?.view.layer.add(CATransition().popFromRight(), forKey: nil)
                parentView.navigationController?.pushViewController(controller, animated: false)
            } else {
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
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        addedStep = true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isFiltering = !isSearchBarEmpty
        if isFiltering == false {
            tableView.reloadData()
        } else {
            tappedSearch = true
            filterContentForSearchText(searchBar.text!)
            tableView.reloadData()
        }
    }
    

}
