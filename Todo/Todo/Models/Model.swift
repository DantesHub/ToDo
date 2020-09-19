
import Foundation
import MobileCoreServices
import UIKit
/// The data model used to populate the table view on app launch.
struct Model {
    private(set) var modelList = [
        "Yosemite",
        "Yellowstone",
        "Theodore Roosevelt",
        "Sequoia",
        "Pinnacles",
        "Mount Rainier",
        "Mammoth Cave",
        "Great Basin",
        "Grand Canyon"
    ]
}
struct GroupList {
    var title: String
    var lists: [String]
    var isExpanded: Bool
}

struct Model2 {
    var modelList2 = [GroupList(title: "Group1", lists: ["List1", "List2", "List3"], isExpanded: true), GroupList(title: "Group2", lists: ["List1", "List2", "List3"], isExpanded: true),GroupList(title: "Group3", lists: ["List1", "List2", "List3"], isExpanded: true),GroupList(title: "Group4", lists: ["List1", "List2", "List3"], isExpanded: true)]
}
extension Model2 {
    mutating func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
           guard sourceIndex != destinationIndex else { return }
           let place = modelList2[sourceIndex]
           modelList2.remove(at: sourceIndex)
           modelList2.insert(place, at: destinationIndex)
       }
       
       /// The method for adding a new item to the table view's data model.
       mutating func addItem(_ place: GroupList, at index: Int) {
           modelList2.insert(place, at: index)
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
        let placeName = modelList2[indexPath.row].title

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
extension Model {
    /// The traditional method for rearranging rows in a table view.
    mutating func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        let place = modelList[sourceIndex]
        modelList.remove(at: sourceIndex)
        modelList.insert(place, at: destinationIndex)
    }
    
    /// The method for adding a new item to the table view's data model.
    mutating func addItem(_ place: String, at index: Int) {
        modelList.insert(place, at: index)
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
        let placeName = modelList[indexPath.row]

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
