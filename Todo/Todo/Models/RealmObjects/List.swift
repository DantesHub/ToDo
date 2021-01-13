//
//  List.swift
//  Todo
//
//  Created by Dante Kim on 9/18/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import Foundation
import RealmSwift
import MobileCoreServices
class ListObject: Object {
    @objc dynamic var name = ""
    @objc dynamic var position = 0
    @objc dynamic var textColor = "white"
    @objc dynamic var backgroundColor = "blue"
    @objc dynamic var backgroundImage = "mountain"
    @objc  dynamic var sortType = ""
    @objc dynamic var reversed = false
    @objc dynamic var customImage: String? = nil
    var groupPositions = List<GroupPosition>()
}



class GroupPosition: Object {
    @objc dynamic var groupName = ""
    @objc dynamic var groupPosition = 0
}

extension Array where Element == ListObject {
    /// The traditional method for rearranging rows in a table view.
    func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        let place = lists[sourceIndex]
        let results = uiRealm.objects(ListObject.self)
        lists.remove(at: sourceIndex)
        lists.insert(place, at: destinationIndex)
        try! uiRealm.write {
            for result in results {
                //src 3 -> dest 5 creates errpr
                let pos = result.position
                    if (sourceIndex < pos && destinationIndex < pos) || (sourceIndex > pos && destinationIndex > pos) {
                    } else if pos == destinationIndex {
                        if sourceIndex > destinationIndex {
                            result.position += 1
                        } else {
                            result.position -= 1
                        }
                    } else if pos == sourceIndex {
                        result.position = destinationIndex
                    } else if sourceIndex > pos {
                        result.position += 1
                    } else if pos < destinationIndex  {
                        result.position -= 1
                    }
            }
            
        }
    }
    
    /// The method for adding a new item to the table view's data model.
    func addItem(_ place: ListObject, at index: Int) {
        lists.insert(place, at: index)
    }
    /**
         A helper function that serves as an interface to the data model,
         called by the implementation of the `tableView(_ canHandle:)` method.
    */
    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    /**
         A helper function that serves as an interface to the data mode, called
         by the `tableView(_:itemsForBeginning:at:)` method.
    */
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let placeName = lists[indexPath.row].name

        let data = placeName.data(using: .utf8)
        let itemProvider = NSItemProvider()
        
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }

        return [
            UIDragItem(itemProvider: itemProvider)
        ]
    }
    

}
