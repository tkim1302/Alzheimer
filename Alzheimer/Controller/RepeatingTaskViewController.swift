import Foundation
import UIKit

class RepeatingTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var repeatingTask: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var tasks : [String] = []
    var models: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let userDefaults = UserDefaults.standard
//        if let storedModels = userDefaults.stringArray(forKey: "Models") {
//            self.models = storedModels
//        }
//
        repeatingTask.delegate = self
        repeatingTask.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            reloadData()
            
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))
            navigationItem.leftBarButtonItem = backButton
    }
    
    func reloadData() {
        if let storedTimeModels = UserDefaults.standard.stringArray(forKey: "Models"),
           let storedTaskModels = UserDefaults.standard.stringArray(forKey: "Tasks"),
           storedTimeModels.count == storedTaskModels.count {
            self.models = storedTimeModels
            self.tasks = storedTaskModels
            repeatingTask.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = repeatingTask.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = tasks[indexPath.row] // Clear the previous text value
        cell.detailTextLabel?.text = models[indexPath.row] // Set the subtitle text
        
        cell.textLabel?.font = UIFont(name: "Arial", size: 22)
        cell.detailTextLabel?.font = UIFont(name: "Arial", size: 16) // Set the font for the subtitle
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from the models array
            models.remove(at: indexPath.row)
            tasks.remove(at: indexPath.row)
            // Delete the corresponding row from the table view
            UserDefaults.standard.set(models, forKey: "Models")
            UserDefaults.standard.set(tasks, forKey: "Tasks")
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Update the models array in UserDefaults
            
        }
    }
    
    @objc func addButtonTapped() {
        guard let addAlarmViewController = storyboard?.instantiateViewController(withIdentifier: "AddAlarmViewController") as? AddAlarmViewController else {
            fatalError("Error: Failed to instantiate AddAlarmViewController")
        }
        navigationController?.pushViewController(addAlarmViewController, animated: true)
    }
    
    @objc func backButtonPressed() {
        if let viewController = navigationController?.viewControllers.first(where: { $0 is ViewController }) {
            navigationController?.popToViewController(viewController, animated: true)
        }
    }
    
    @IBAction func tapEdit() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))
        
        if repeatingTask.isEditing {
            editButton.title = "Edit"
            navigationItem.leftBarButtonItem = backButton
            repeatingTask.isEditing = false
        } else {
            editButton.title = "Done"
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = addButton
            repeatingTask.isEditing = true
        }
    }
}
