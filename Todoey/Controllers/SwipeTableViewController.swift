//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Ron Yi on 2018/8/11.
//  Copyright © 2018年 Ron Yi. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //讓sub class也可以繼承row高度
        tableView.rowHeight = 80.0
        
        tableView.separatorStyle = .none //消除cell的格線
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //在storyboard把每個sub class的cell改成相同id
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }

    //MARK: Swipe Delete Methods
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.updateModel(at: indexPath)
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    //增加Swipe滑動直接刪除，不用再點Delete，但保留原有點Delete刪除功能
    //增加這功能要把deleteAction裡的tableView.reloadData()刪除，不然會crash
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        
        return options
    }
    
    func updateModel(at indexPath:IndexPath) {
        //Update our data
    }
    
}
