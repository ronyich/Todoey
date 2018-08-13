//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ron Yi on 2018/8/7.
//  Copyright © 2018年 Ron Yi. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    
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
        
        //從super class繼承過來的cell (已經是Swipe cell了)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let category = categories?[indexPath.row]
        cell.textLabel?.text = category?.name ?? "No Categories Add yet."
        
        //最後的""代表預設值，這邊用"66CCFF"為水藍色
        guard let categoryColour = UIColor(hexString: category?.colour ?? "66CCFF") else{fatalError()}
        
        cell.backgroundColor = categoryColour
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColour, isFlat: true)

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

    
    //MARK: Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
            //在新增Category時亂數取得顏色16進位代碼的字串，存到.colour
            newCategory.colour = UIColor.randomFlat.hexValue()
            
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

    //MARK: - Data Manipulation Methods
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
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
     
        //super.updateModel(at: indexPath)，如果要保留執行super class方法裡的內容，就加入開頭這行，代表先執行super class這個方法的內容，再複寫加入新功能，不加就是全新的功能。
        
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error Delete Category, \(error)")
            }
        }
    }
}

