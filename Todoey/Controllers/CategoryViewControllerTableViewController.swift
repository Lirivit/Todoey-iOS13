

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewControllerTableViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller doesn't exist.")}
        
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
        
        loadCategories()
        
    }
    //Mark: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 // nil coalasing operator
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row]    {
            
        cell.textLabel?.text = category.name
        
        guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
            
        cell.backgroundColor = categoryColour
        
        cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
            
        }
        return cell
        
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            // here will happen that when user clicks the Add item button in our UIalert
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new category"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }

    //Mark: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row] 
        }
    }
    //Mark: - Data Manipualtion Methods
    
    func save(category: Category) {
        
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
            
        tableView.reloadData()
    }
 
    func loadCategories() {
        
        categories = realm.objects(Category.self) // fetching all the objects that belongs to category data type
        
        tableView.reloadData()
    }
//MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category \(error)")
            }
        }
    }
}

    


   
    
    
