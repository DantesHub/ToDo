//
//  Task.swift
//  Todo
//
//  Created by Dante Kim on 11/4/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import Foundation
import RealmSwift
import MobileCoreServices

class TaskObject: Object {
    @objc dynamic var name = ""
    @objc dynamic var position = 0
    @objc dynamic var favorited  = false
    @objc dynamic var reminder = ""
    @objc dynamic var planned = ""
    @objc dynamic var parentList = ""
    @objc dynamic var priority = 0
    @objc dynamic var completed = false
    @objc dynamic var createdAt = ""
    @objc dynamic var repeated = ""
    @objc dynamic var completedDate = Date()
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var note = ""
    var steps = List<Step>()
    
    override static func primaryKey() -> String? {
        return "id"
      }
}

class Step: Object {
    @objc dynamic var stepName = ""
    @objc dynamic var done = false
}

extension Array where Element == TaskObject {
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let placeName = indexPath.section == 0 ? tasksList[indexPath.row].name : completedTasks[indexPath.row].name

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
    /// The method for adding a new item to the table view's data model.
    func addItem(_ place: TaskObject
                 , at index: Int) {
        tasksList.insert(place, at: index)
    }
    /**
         A helper function that serves as an interface to the data model,
         called by the implementation of the `tableView(_ canHandle:)` method.
    */
    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
}
