//
//  ViewController.swift
//  coreDataTest
//
//  Created by Марк Голубев on 09.02.2023.
//

import UIKit
import CoreData

class ToDoListTableViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    // context for CoreData == stage area in git
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // search bar
    var searchController = UISearchController()
    var categoryPredicate = "parentCategory.name MATCHES %@"
    var containsTitlePredicate = "title CONTAINS[cd] %@"
    
    var selectedCategory: ItemsCategory? {
        didSet {
            loadData()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // UISearchController set up
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search here..."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        // refresher setup (just for exploring)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Add new Item
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        // created controller
        let ac = UIAlertController(title: "Add Item to your to do list", message: nil, preferredStyle: .alert)
        // added TextField
        ac.addTextField()
        ac.textFields?[0].placeholder = "Create new Item"
        
        
        // created action button
        let addAction = UIAlertAction(title: "Add Item", style: .default) {
            // trying to avoid strong reference
            [weak self, weak ac] action in
            // checked textField is not nil
            guard let item = ac?.textFields?[0].text, item != "" else { return }
            // use button Submit using answer and method out of closure
            self?.submit(item)
        }
        
        ac.addAction(addAction)
        present(ac, animated: true)
    }
    
    // added submit function for action controller
    func submit(_ item: String) {
        
        let newItem = Item(context: context)
        newItem.title = item
        newItem.done = false
        newItem.parentCategory = selectedCategory
        itemArray.insert(newItem, at: 0)
        saveData()
        
        // update one row
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        return
    }
    
    // method fo refresh data
    @objc func refreshData() {
        loadData()
        
        guard let refreshControl = refreshControl else { return }
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    // MARK: - CRUD for CoreData
    
    func saveData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
        
    }
    
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: categoryPredicate, selectedCategory!.name!)
        
        // array of predicate
        if let additonalPredicate = predicate {
            request.predicate =  NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additonalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray =  try context.fetch(request).reversed()
        } catch {
            print("Error loading context \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func deleteData(with indexPath: IndexPath) {
        
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        
        
    }
    
    // MARK: - Table view data source and delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count
    }
    
    // setup cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: "applelogo")
        content.text = itemArray[indexPath.row].title
        cell.contentConfiguration = content
        
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Update for CoreData 131-133
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //       OR itemArray[indexPath.row].setValue(true, forKey: "done")
        saveData()
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // add delete cell functional
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteData(with: indexPath)
            saveData()
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
    }
}

// MARK: - UISearchBarDelegate

extension ToDoListTableViewController: UISearchBarDelegate {
    // filter data when you presed search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: containsTitlePredicate, searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadData(with: request, predicate: predicate)
    }
    
    // use this method to update(filter) table when you type the text and refresh when delete all of symbols
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
        } else {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: containsTitlePredicate, searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadData(with: request, predicate: predicate)
        }
    }
    
    // refresh table when you pressed cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadData()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
}


