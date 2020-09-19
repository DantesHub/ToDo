//
//  List.swift
//  Todo
//
//  Created by Dante Kim on 9/18/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import Foundation
import RealmSwift

class ListObject: Object {
    @objc dynamic var name = ""
    @objc dynamic var position = ""
}
