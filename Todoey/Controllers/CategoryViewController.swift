//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ron Yi on 2018/8/7.
//  Copyright © 2018年 Ron Yi. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()
        
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        //設定使用者點選的categoryArray索引，把結果存到selectedCategory(將這個變數在TodoListVC宣告，selectedCategory用途在於接這邊使用者點選的索引值)
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: TableView Delete Methods
    //尚未解決：刪除Category，item還保留的bug
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            context.delete(categoryArray[indexPath.row])
            categoryArray.remove(at: indexPath.row)
       
            //context.delete(itemArray[indexPath.row])
            
            saveCategory()
        }
    }
    
    //MARK: Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categoryArray.append(newCategory)
            self.saveCategory()
            
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

    
    func saveCategory() {
        
        do{
            try context.save()
        }catch{
            print("Error Saving context, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategory() {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            categoryArray = try context.fetch(request)
        }catch{
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
    
}
