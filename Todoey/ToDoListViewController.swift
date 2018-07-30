//
//  ViewController.swift
//  Todoey
//
//  Created by Ron Yi on 2018/7/29.
//  Copyright © 2018年 Ron Yi. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    var itemArray = ["Find Mike","Buy Eggos","Destory Demogorgon"]
    
    //var addTextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        //利用if判斷是否有做checkmark記號，如果有就消除，沒有的話就打勾
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        //選到該列時會有短暫淡出動畫
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            alert.addTextField { (alertTextField) in
                self.itemArray.append(textField.text!)
                
                self.tableView.reloadData()
            }
        }
        
        
        //點選+後出現文字輸入框，alert的preferredStyle不能選.actionSheet，不支援文字輸入框功能
        alert.addTextField { (alertTextField) in

            alertTextField.placeholder = "Create new item"
            textField = alertTextField
          
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(action)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
        
    }
}

