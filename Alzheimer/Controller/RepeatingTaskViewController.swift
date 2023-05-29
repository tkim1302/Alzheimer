import Foundation
import UIKit

class RepeatingTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var repeatingTask: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var tasks : [String] = []
    var models: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        for row in 0..<models.count {
            let switchKey = "SwitchValue_\(row)"
            let switchValue = UserDefaults.standard.object(forKey: switchKey) as? Bool
            if let switchControl = repeatingTask.cellForRow(at: IndexPath(row: row, section: 0))?.accessoryView as? UISwitch {
                switchControl.isOn = switchValue ?? true
                switchValueChanged(switchControl)
            }
        }
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
        
        cell.textLabel?.text = tasks[indexPath.row]
        cell.detailTextLabel?.text = models[indexPath.row]
        
        cell.textLabel?.font = UIFont(name: "Arial", size: 22)
        cell.detailTextLabel?.font = UIFont(name: "Arial", size: 16)
        
        if repeatingTask.isEditing { //hide the switch when editing
            cell.accessoryView = nil
        } else {
            let switchKey = "SwitchValue_\(indexPath.row)"
            let switchValue = UserDefaults.standard.object(forKey: switchKey) as? Bool
            

            let defaultValue = switchValue ?? true
            let switchControl = UISwitch()
            
            switchControl.isOn = defaultValue
            

            switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            
            
            switchControl.frame = CGRect(x: cell.contentView.frame.size.width - switchControl.frame.size.width - 16, y: (cell.contentView.frame.size.height - switchControl.frame.size.height) / 2, width: switchControl.frame.size.width, height: switchControl.frame.size.height)
            
           
            switchControl.tag = indexPath.row
            
           
            cell.accessoryView = switchControl
            
            switchValueChanged(switchControl)
        }
        
        return cell
    }

    @objc func switchValueChanged(_ sender: UISwitch) {
        let rowIndex = sender.tag
        
      
        let switchValue = sender.isOn
        UserDefaults.standard.set(switchValue, forKey: "SwitchValue_\(rowIndex)") // Store the switch value in UserDefaults
        
        if switchValue {
            let timeModel = models[rowIndex]
            let taskModel = tasks[rowIndex]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            guard let targetTime = dateFormatter.date(from: timeModel) else {
                print("Invalid time format")
                return
            }
            
            let now = Date()
            let calendar = Calendar.current
            
            let targetComponents = calendar.dateComponents([.hour, .minute], from: targetTime)
            let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
            
            var triggerComponents = DateComponents()
            triggerComponents.hour = targetComponents.hour
            triggerComponents.minute = targetComponents.minute
            
            if let currentHour = currentComponents.hour, let targetHour = targetComponents.hour {
                if currentHour > targetHour || (currentHour == targetHour && currentComponents.minute! > targetComponents.minute!) {
                    // If the target time has already passed today, schedule it for tomorrow
                    triggerComponents.day = calendar.component(.day, from: now) + 1
                } else {
                    // Schedule it for today
                    triggerComponents.day = calendar.component(.day, from: now)
                }
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                
                let content = UNMutableNotificationContent()
                content.title = "Alarm"
                content.body = taskModel
                content.sound = UNNotificationSound.default
                
                let request = UNNotificationRequest(identifier: taskModel, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error adding notification: \(error.localizedDescription)")
                    } else {
                        print("Notification added successfully")
                    }
                }
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
            reloadData()
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
    func addNotification(at time: TimeInterval, forTask task: String) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = task
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        
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
