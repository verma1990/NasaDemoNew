//
//  ViewController.swift
//  NasaDemo
//
//  Created by Admin on 22/03/22.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var btnLike: UIButton?
    @IBOutlet var labelTitle: UILabel?
    @IBOutlet var labelDescription: UITextView?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var textFieldDatePicker: UITextField?
    let activityIndicator = UIActivityIndicatorView(style: .large)
    private var homeViewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if checkIfValueWasSaved(date: self.homeViewModel.date ?? "") == true{
            btnLike?.setTitle("Liked", for: .normal)
        }else{
            btnLike?.setTitle("Like", for: .normal)
        }
    }
   
    //Set Date picket through textfield
    private func setDatePicker() {
        
        self.textFieldDatePicker?.rightViewMode = UITextField.ViewMode.always
        self.textFieldDatePicker?.datePicker(target: self,
                                     doneAction: #selector(doneAction),
                                     cancelAction: #selector(cancelAction),
                                     datePickerMode: .date)
        
        activityIndicator.color = UIColor.gray
        self.view.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
    }
    
    //Call ViewModel to get Data
    private func getDataByDate(date:Date) {
        
        if Reachability.isConnectedToNetwork(){
            activityIndicator.startAnimating()
            homeViewModel.callApodApi(queryDate: date) {[weak self] (isSuccess,error) in
                if(isSuccess) {
                    self?.updateUIData()
                }else {
                    self?.showAlert(error: error)
                }
            }
        }else{
            showAlert(error: "Internet Connection not Available!")
        }
        
    }
    
    
    @IBAction func likeAction(_ sender: Any) {
        if(self.homeViewModel.date != nil){
            self.saveApod(homeModel: self.homeViewModel)
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ListViewController") as? ListViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
   private func saveApod(homeModel: HomeViewModel) {
      
       if checkIfValueWasSaved(date: homeModel.date ?? "") == true{
           btnLike?.setTitle("Liked", for: .normal)
           
       }else{
           var apod: [NSManagedObject] = []
           guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
             return
           }

           let managedContext = appDelegate.persistentContainer.viewContext
           let entity = NSEntityDescription.entity(forEntityName: "APOD", in: managedContext)!
           let apodData = NSManagedObject(entity: entity, insertInto: managedContext)
             apodData.setValue(homeModel.title, forKeyPath: "title")
             apodData.setValue(homeModel.explanation, forKeyPath: "discription")
             apodData.setValue(homeModel.url, forKeyPath: "imageUrl")
           apodData.setValue(homeModel.date, forKeyPath: "date")
           do {
             try managedContext.save()
             apod.append(apodData)
             btnLike?.setTitle("Liked", for: .normal)
           } catch let error as NSError {
             print("Could not save. \(error), \(error.userInfo)")
           }
       }
        
      
    }
    
    private func checkIfValueWasSaved(date : String) -> Bool{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "APOD")

        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        // Add Predicate
        let predicate = NSPredicate(format: "date CONTAINS[c] %@", date)
        fetchRequest.predicate = predicate

        do {
            let records = try managedContext.fetch(fetchRequest) as! [NSManagedObject]

            for record in records {
                print(record.value(forKey: "date") ?? "no name")
                return true
            }
            return false

        } catch {
            print(error)
            return false
        }
    }
    
    //DatePicker Done Action
    @objc private func doneAction() {
        
        
        if let datePickerView = self.textFieldDatePicker?.inputView as? UIDatePicker {
            
            DispatchQueue.main.async { [self] in
                self.textFieldDatePicker?.resignFirstResponder()
                self.activityIndicator.startAnimating()
                self.clearUIData()
            }
            //Call Selected Date APod
            getDataByDate(date: datePickerView.date)
            if checkIfValueWasSaved(date: updateQueryDate(queryDate: datePickerView.date)) == true{
                btnLike?.setTitle("Liked", for: .normal)
            }else{
                btnLike?.setTitle("Like", for: .normal)
            }
        }
    }
    
    private func updateQueryDate(queryDate: Date) -> String{
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = Constants.DateFormatForApod
         let dateString = dateFormatter.string(from: queryDate)
        return dateString
     }
    
    //DatePicker Cancel Action
    @objc private func cancelAction() {
        self.textFieldDatePicker?.resignFirstResponder()
    }
    
    //Clear UI Data before New API call
    private func clearUIData() {
        
        self.labelTitle?.text = ""
        self.labelDescription?.text = ""
        self.textFieldDatePicker?.text = ""
        self.imageView?.image = nil
    }
    
    //Update UI Data
    private func updateUIData() {
        
        DispatchQueue.main.async {
            self.labelTitle?.text = self.homeViewModel.title
            self.labelDescription?.text = self.homeViewModel.explanation
            self.textFieldDatePicker?.text = self.homeViewModel.date
            if (self.homeViewModel.media_type == Constants.MediaType.image) {
                self.imageView?.loadImage(withUrl: self.homeViewModel.url ?? "")
            }else {
                self.imageView?.image = UIImage(named: Constants.NoImage)
            }
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    //Show Error Alert
   private func showAlert(error: String?) {
        
        DispatchQueue.main.async {
            
            self.activityIndicator.stopAnimating()
            let alert = UIAlertController(title: Constants.ErrorText, message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.OKText, style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

}

