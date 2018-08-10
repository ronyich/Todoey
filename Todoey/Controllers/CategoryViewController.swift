//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ron Yi on 2018/8/7.
//  Copyright © 2018年 Ron Yi. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    //Results是Realm裡面的一種容器型別，並會自動更新並監控修改，所以就不需要再加原本addButtonPressed，action裡的self.categories.append(newCategory)這行
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        //查詢Realm File路徑
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Add yet."
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //如果categories?.count == nil，就return 1 (因為若app剛建立count會是空的)
        return categories?.count ?? 1
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        //設定使用者點選的categoryArray索引，把結果存到selectedCategory(將這個變數在TodoListVC宣告，selectedCategory用途在於接這邊使用者點選的索引值)
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: TableView Delete Methods
    //尚未解決：刪除Category，item還保留的bug
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//        if editingStyle == .delete {
//
//            context.delete(categoryArray[indexPath.row])
//            categoryArray.remove(at: indexPath.row)
//
//            //context.delete(itemArray[indexPath.row])
//
//            saveCategory()
//        }
//    }
    
    //MARK: Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
            
            self.save(category: newCategory)
            
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (alertTextField) in
            textField.placeholder = "Input a Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(actionCancel)
        
        present(alert, animated: true)
    }

    
    func save(category: Category) {
        
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error Saving context, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        //這代表從realm裡面屬於Category的所有項目
        categories = realm.objects(Category.self)
        

        tableView.reloadData()
    }
    
}
