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
    //建立一個標準版的UserDefaults，用來永久儲存
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = Item()
        newItem.title = "Find Mike"
        itemArray.append(newItem)
        
        let newItem2 = Item()
        newItem2.title = "Buy Eggos"
        itemArray.append(newItem2)
        
        let newItem3 = Item()
        newItem3.title = "Destory"
        itemArray.append(newItem3)
        
        //讓app一開始就先檢索"ToDoListArray"目錄裡的資料，讓以前存過資料顯示出來
        if let items = defaults.array(forKey: "ToDoListArray") as? [Item] {
            itemArray = items
        }
        
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
        
        //if item.done == true {
        //    cell.accessoryType = .checkmark
        //}else{
        //    cell.accessoryType = .none
        //}
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //這一行等同於下面5行判斷式
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //if itemArray[indexPath.row].done == false {
        //    itemArray[indexPath.row].done = true
        //}else{
        //    itemArray[indexPath.row].done = false
        //}
        
        //選到該列時會有短暫淡出動畫
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadData()
    }
    
    //MARK: Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            alert.addTextField { (alertTextField) in
                
                let newItem = Item()
                newItem.title = textField.text!
                
                //把輸入的內容存到itemArray
                self.itemArray.append(newItem)
                
                //把資料存到"ToDoListArray"目錄裡，還需在viewDidLoad裡設定檢索(讀取)itemArray
                self.defaults.setValue(self.itemArray, forKey: "ToDoListArray")
                
                //reload之後才會將更新的資料顯示在tableView中
                self.tableView.reloadData()
            }
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
}

