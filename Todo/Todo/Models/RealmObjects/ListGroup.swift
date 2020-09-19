//
//  ListGroup.swift
//  Todo
//
//  Created by Dante Kim on 9/18/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import Foundation
import RealmSwift

class ListGroup: Object {
    @objc dynamic var name = "Luigi"
    @objc dynamic var position = ""
    var lists = List<ListObject>()
}


