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
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else {
                print("Notification authorization denied")
            }
        }
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
        
        if repeatingTask.isEditing {
            // Hide the switch when editing
            cell.accessoryView = nil
        } else {
            // Show the switch when not editing
            
            // Check if the switch value exists in UserDefaults
            let switchKey = "SwitchValue_\(indexPath.row)"
            let switchValue = UserDefaults.standard.object(forKey: switchKey) as? Bool
            
            // If switch value is nil, set the default value to true
            let defaultValue = switchValue ?? true
            
            // Create a UISwitch
            let switchControl = UISwitch()
            
            // Set the switch value
            switchControl.isOn = defaultValue
            
            // Add a target-action to handle switch value changes
            switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            
            // Set the frame for the switch
            switchControl.frame = CGRect(x: cell.contentView.frame.size.width - switchControl.frame.size.width - 16, y: (cell.contentView.frame.size.height - switchControl.frame.size.height) / 2, width: switchControl.frame.size.width, height: switchControl.frame.size.height)
            
            // Assign a tag to the switch based on the row index
            switchControl.tag = indexPath.row
            
            // Set the switch as the accessory view of the cell
            cell.accessoryView = switchControl
        }
        
        return cell
    }

    @objc func switchValueChanged(_ sender: UISwitch) {
        let rowIndex = sender.tag
        
        // Update your data model based on the switch value
        let switchValue = sender.isOn
        UserDefaults.standard.set(switchValue, forKey: "SwitchValue_\(rowIndex)") // Store the switch value in UserDefaults
        
        if switchValue {
            let timeModel = models[rowIndex]
            let taskModel = tasks[rowIndex]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            if let date = dateFormatter.date(from: timeModel) {
                addNotification(at: date, forTask: taskModel)
            }
        } else {
            let taskModel = tasks[rowIndex]
            cancelNotification(forTask: taskModel)
        }
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
    func addNotification(at date: Date, forTask task: String) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = task
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: task, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification added successfully")
            }
        }
    }
    func cancelNotification(forTask task: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task])
    }
    
}
