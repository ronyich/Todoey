//
//  Category.swift
//  Todoey
//
//  Created by Ron Yi on 2018/8/8.
//  Copyright © 2018年 Ron Yi. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = "" 
    
    //用Realm的List型別，讓Category跟Item類別建立關聯
    //let array = Array<Int>() 等同這種寫法
    let items = List<Item>()
}
