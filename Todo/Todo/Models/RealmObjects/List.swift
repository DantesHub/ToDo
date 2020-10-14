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
    dynamic var groupPositions = [GroupPositions]()
    dynamic var id = UUID()
    
//    override static func primaryKey() -> String? {
//        return "name"
//    }
}



class GroupPositions: Object {
    @objc dynamic var groupName = ""
    @objc dynamic var groupPosition = 0
}
extension Array where Element == ListObject {
    /// The traditional method for rearranging rows in a table view.
    func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        let place = lists[sourceIndex]
        lists.remove(at: sourceIndex)
        lists.insert(place, at: destinationIndex)
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
