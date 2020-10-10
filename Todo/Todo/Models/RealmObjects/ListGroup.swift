//
//  ListGroup.swift
//  Todo
//
//  Created by Dante Kim on 9/18/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import Foundation
import RealmSwift
import MobileCoreServices

import UIKit

class ListGroup: Object {
    @objc dynamic var name = "Luigi"
    @objc dynamic var position = 0
    @objc dynamic var isExpanded = true
    var lists = List<ListObject>()
}


extension ListGroup {
//    func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
//           guard sourceIndex != destinationIndex else { return }
//           let place = modelList2[sourceIndex]
//           modelList2.remove(at: sourceIndex)
//           modelList2.insert(place, at: destinationIndex)
//       }
//
//       /// The method for adding a new item to the table view's data model.
//       mutating func addItem(_ place: GroupList, at index: Int) {
//           modelList2.insert(place, at: index)
//       }
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
    func dragSections(for section: Int) -> [UIDragItem] {
        let placeName = lists[section].name

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
