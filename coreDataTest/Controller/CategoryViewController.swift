//
//  CategoryViewController.swift
//  coreDataTest
//
//  Created by Марк Голубев on 11.02.2023.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [ItemsCategory]()
    // context for CoreData == stage area in git
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // created controller
        let ac = UIAlertController(title: "Add Category to your to do list", message: nil, preferredStyle: .alert)
        // added TextField
        ac.addTextField()
        ac.textFields?[0].placeholder = "Create new Category"
        
        
        // created action button
        let addAction = UIAlertAction(title: "Add Category", style: .default) {
            // trying to avoid strong reference
            [weak self, weak ac] action in
            // checked textField is not nil
            guard let category = ac?.textFields?[0].text, category != "" else { return }
            // use button Submit using answer and method out of closure
            self?.submit(category)
        }
        
        ac.addAction(addAction)
        present(ac, animated: true)
    }
    
    // added submit function with word checking
    func submit(_ category: String) {
        
        let newCategory = ItemsCategory(context: context)
        newCategory.name = category
        categoryArray.insert(newCategory, at: 0)
        saveData()
        
        // update one row
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        return
    }
    
    // MARK: - CRUD for CoreData
    
    func saveData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
        
    }
    
    
    func loadData(with request: NSFetchRequest<ItemsCategory> = ItemsCategory.fetchRequest()) {
        
        do {
            categoryArray =  try context.fetch(request).reversed()
        } catch {
            print("Error loading context \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func deleteData(with indexPath: IndexPath) {
        
        context.delete(categoryArray[indexPath.row])
        categoryArray.remove(at: indexPath.row)
        
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: "puzzlepiece.fill")
        content.text = categoryArray[indexPath.row].name
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItemsSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteData(with: indexPath)
            saveData()
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }

    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
 

}
