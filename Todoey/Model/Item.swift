//
//  Item.swift
//  Todoey
//
//  Created by Ron Yi on 2018/8/1.
//  Copyright © 2018年 Ron Yi. All rights reserved.
//

import Foundation

//遵循Encodable協定，讓Item Class擁有將自己編碼成plist或JSON類型資料的能力
//但是裡面的屬性就只能是標準資料類型(String,array等等)，不能是自定義的類型(如自己創造的class)
//Codable讓Item同時有Encodable(編碼) & Decodable(解碼)的功能
class Item:Codable {
    var title: String = ""
    var done: Bool = false
    
}
