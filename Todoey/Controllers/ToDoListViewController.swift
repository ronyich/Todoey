//
//  ViewController.swift
//  Todoey
//
//  Created by Ron Yi on 2018/7/29.
//  Copyright © 2018年 Ron Yi. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    //建立一個儲存資料的主目錄
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //建立一個標準版的UserDefaults，用來永久儲存，創建dataPath後
    //let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(dataFilePath)
        
        loadItems()
        
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //判斷若item.done為true就做checkmark打勾記號，false的話就做空白記號
        //Ternary operator 三元運算子，同下面五行的結果
        //Value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done ? .checkmark : .none
        
//        if item.done == true {
//            cell.accessoryType = .checkmark
//        }else{
//            cell.accessoryType = .none
//        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //這一行等同於下面5行判斷式，點下該cell就會反轉done裡的true false結果
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
//        if itemArray[indexPath.row].done == false {
//            itemArray[indexPath.row].done = true
//        }else{
//            itemArray[indexPath.row].done = false
//        }
        
        //選到該列時會有短暫淡出動畫
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
                
                let newItem = Item()
                newItem.title = textField.text!
                
                //把輸入的內容存到itemArray
                self.itemArray.append(newItem)
            
                self.saveItems()
                
                //reload之後才會將更新的資料顯示在tableView中
                //self.tableView.reloadData()
            
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //點選+後出現文字輸入框，alert的preferredStyle不能選.actionSheet，不支援文字輸入框功能
        //輸入玩文字後按下Add Item，會執行該action裡面的內容
        alert.addTextField { (alertTextField) in

            alertTextField.placeholder = "Create new item"
            textField = alertTextField
          
        }
        
        alert.addAction(action)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveItems() {
        //把資料嘗試寫入dataPath裡面，要將Item class遵從Encodeble協定，才能在新增資料時
        //自動將itemArray資料編碼，並存到dataFilePath目錄下的Items.plist檔案中。
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        }catch{
            print("Error encoding item array, \(error)")
        }
        tableView.reloadData()
    }
    //用Decoder解碼Items.plist檔案
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            }catch{
                print("Error decoding item array,\(error)")
            }
        }
    }
    
}

