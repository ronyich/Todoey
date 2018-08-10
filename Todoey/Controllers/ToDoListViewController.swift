//
//  ViewController.swift
//  Todoey
//
//  Created by Ron Yi on 2018/7/29.
//  Copyright © 2018年 Ron Yi. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    var todoItems:Results<Item>?
    
    let realm = try! Realm()
    
    //使用者點選的索引值，是從CategoryVC丟過來的，並用didSet直接load現有資料。
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            //判斷若item.done為true就做checkmark打勾記號，false的話就做空白記號
            //Ternary operator 三元運算子
            //Value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
            
        }else{
            cell.textLabel?.text = "No Items Added."
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //反轉item.done的結果，並寫入realm
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error Saving done status, \(error)")
            }
        }
        
        //選到該列時會有短暫淡出動畫，用意是在選到cell的灰色背景消失
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadData()
    }
    
    //MARK: TableView Delete Methods
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            
            if let item = todoItems?[indexPath.row] {
                do{
                    try realm.write {
                        realm.delete(item)
                    
                    }
                }catch{
                    print("Error delete item, \(error)")
                }
            }
            tableView.reloadData()
        }
    }
    
    
    //MARK: Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                
                do {
                    try self.realm.write {
                        let newItem = Item()
                        //DataModel裡的屬性若沒有勾選Optional，那就都要有值，才能儲存成功
                        newItem.title = textField.text!
                        newItem.dateCreated = Date() //讓每個item新增時都有建立時間
                        //把輸入的文字存到Category.items這個關聯屬性，目的在把資料存成像是List清單的結構，一個Category有複數Items，依照各自的路徑排好。
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new items, \(error)")
                }                
            }
            
            self.tableView.reloadData()
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
    
    func save(item:Item? = nil) {
       
        
    }
    
    //用fetchRequest() 請求取回資料 (從context中取回)，把取回的資料存到todoItems中
    //在方法中給參數明確的值，可以在呼叫時不加外部參數，如保持loadItem()，但其實裡面已經包含request的值
    func loadItems() {
        //從關聯的Category.items拿到所有title資料並排序，
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        

        tableView.reloadData()
    }

    
}

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //設定查詢條件並以關鍵字"title"排序，ascending意思為上升排序
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    //當輸入的文字改變時，會執行這個方法裡的內容
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            
            loadItems()

            //主佇列：main跟畫面有關的工作。async異步方法：一執行完異步方法後跳出函式，並繼續原本函式的工作
            //因為還需要繼續使用resignFirstResponder()方法，監聽使用者是否會刪除整列文字讓count == 0
            //讓resignFirstResponder()繼續在背景執行監聽工作，不這樣寫就只會執行一次該方法。
            DispatchQueue.main.async {
                //在searchBar.text?.count == 0時，解除自己為第一響應者的狀態，並收起鍵盤。
                searchBar.resignFirstResponder()
            }

        }
    }
}
