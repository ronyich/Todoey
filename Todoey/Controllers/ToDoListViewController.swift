//
//  ViewController.swift
//  Todoey
//
//  Created by Ron Yi on 2018/7/29.
//  Copyright © 2018年 Ron Yi. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    //使用者點選的索引值，是從CategoryVC丟過來的，並用didSet直接load現有資料。
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    //存到CoreData，設定把Item(DataModel)資料存到AppDelegate的永久儲存容器中
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    //建立一個標準版的UserDefaults，用來永久儲存，創建dataPath後
    //let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func refreshDataButton(_ sender: UIBarButtonItem) {
        tableView.reloadData()
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //判斷若item.done為true就做checkmark打勾記號，false的話就做空白記號
        //Ternary operator 三元運算子
        //Value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        //點下該cell就會反轉done裡的true false結果
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        
        //選到該列時會有短暫淡出動畫
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: TableView Delete Methods
    //若要刪除row，要先從context刪除，再刪除itemArray的indexPath.row。
    //若顛倒可能會因為找不到itemArray的索引而crash。
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            
            saveItems()
        }
    }
    
    
    //MARK: Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            //DataModel裡的屬性若沒有勾選Optional，那就都要有值，才能儲存成功
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory //指定父類別資料來源

            
            //把輸入的內容存到itemArray
            self.itemArray.append(newItem)
            
            self.saveItems()
            
            
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
       
        do {
            try context.save()
        }catch{
            print("Error saving context, \(error)")
        }
        tableView.reloadData()
    }
    
    //用fetchRequest() 請求取回資料 (從context中取回)，把取回的資料存到itemArray中
    //在方法中給參數明確的值，可以在呼叫時不加外部參數，如保持loadItem()，但其實裡面已經包含request的值
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest(),predicate:NSPredicate? = nil) {
        
        //過濾讀取父類別資料的結果
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        //CompoundPredicate：複合式謂詞(加入多個篩選條件) additionalPredicate：額外謂詞
        //additionalPredicate是讓其他功能可以加入自己的篩選條件，如搜尋功能自己的predicate套用進去
        //，搜尋功能就同時有兩種(loadItems跟自己)篩選條件，讓篩選更精確。
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    //未完成
    func deleteNilData() {
        let newItem = Item(context: self.context)
        
        let resultArray = [newItem.parentCategory].filter({ (item) -> Bool in
            return item == nil
        })
        print("@@@\(resultArray.count)")
    }
    
}

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        //設定查詢條件，在請求資料時一併執行查詢條件
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //設定以關鍵字"title"排序，ascending意思為上升排序
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
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
