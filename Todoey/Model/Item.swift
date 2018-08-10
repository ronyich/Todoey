//
//  Item.swift
//  Todoey
//
//  Created by Ron Yi on 2018/8/8.
//  Copyright © 2018年 Ron Yi. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    //使用dynamic代表會監聽這個變數，偵測變數值是否改變，如同搜尋的監聽字數功能
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //設定父類連結對象，跟Category類別建立關聯
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
