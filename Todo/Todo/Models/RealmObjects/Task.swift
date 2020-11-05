//
//  Task.swift
//  Todo
//
//  Created by Dante Kim on 11/4/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import Foundation
import RealmSwift

class TaskObject: Object {
    @objc dynamic var name = ""
    @objc dynamic var position = 0
    @objc dynamic var favorited  = false
    @objc dynamic var reminder = ""
    @objc dynamic var planned = ""
    @objc dynamic var parentList = ""
    var steps = List<Step>()
}

class Step: Object {
    @objc dynamic var stepName = ""
    @objc dynamic var done = false
}
