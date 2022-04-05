//
//  ListViewController.swift
//  NasaDemo
//
//  Created by Admin on 04/04/22.
//

import UIKit
import CoreData

class ListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  var apod: [NSManagedObject] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "The List"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    tableView.estimatedRowHeight = 80
    tableView.rowHeight = UITableView.automaticDimension
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "APOD")

    do {
      apod = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }

}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return apod.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let person = apod[indexPath.row]
    //let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
      var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
      if cell == nil || cell?.detailTextLabel == nil {
          cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
      }
      cell?.textLabel?.text = person.value(forKeyPath: "title") as? String
      cell?.detailTextLabel?.text = person.value(forKeyPath: "discription") as? String
      cell?.imageView?.loadImage(withUrl: person.value(forKeyPath: "imageUrl") as? String ?? "" )
      
    return cell ?? UITableViewCell()
  }
    
//    func tableView(tableView: UITableView,
//        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
}
