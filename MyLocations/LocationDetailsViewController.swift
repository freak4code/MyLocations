//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Shahriar Nasim Nafi on 3/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class LocationDetailsViewController: UITableViewController {
    
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    var image: UIImage?
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var navTitle: String?
    var descriptionText = ""
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark : CLPlacemark?
    var category = "No Category"
    var gestureRecognizer: UITapGestureRecognizer!
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // Using own way.....(See 698 - 703 for a long code :D)
    var date = Date()
    
    var location = Location()
    
    
    var observer: Any!
    
    var locationToEdit: Location?
    
    
    
    
    deinit {
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer)
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        navigationController?.isNavigationBarHidden = false
    //    }
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenForBackgroundNotification()
        
        if let location = locationToEdit{
                title = "Edit Location"
                self.location = location
                descriptionText = location.locationDescription
                coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                date = location.date
                placemark = location.placemark
                category = location.category
                if location.hasPhoto {
                    if let image = location.photoImage {
                        show(image)
                    }
                }
        }else{
            title = "Add New Location"
        }
        
   
        descriptionTextView.text = descriptionText
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        if let placemark = placemark{
            addressLabel.text = Helper._String(from: placemark)
        }else{
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = Helper.formate(date: date)
        categoryLabel.text = category
        
        
        gestureRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1{
            return indexPath
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0{
            descriptionTextView.becomeFirstResponder()
        }else if indexPath.section == 1 && indexPath.row == 0{
            pickPhoto()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        cell.selectedBackgroundView = selection
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SelectCategory"{
            let destination = segue.destination as! CategoryPickerViewController
            //  destination.delegate = self
            destination.selectedCategory = category
            
            
        }
    }
    
    
    
    // MARK:- Actions
    @IBAction func done() {
        
        //  navigationController?.popViewController(animated: true)
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        if let editing = locationToEdit{
            hudView.text = "Updated"
            location = editing
        }else{
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext) // for new location
            location.photoID = nil
        }
        
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.locationDescription = descriptionTextView.text!
        location.category = category
        location.date = date
        location.placemark = placemark
        
        
        if let image = image{
            
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            if let data = image.jpegData(compressionQuality: 0.5){
                do{
                    try data.write(to: location.photoUrl, options: .atomic)
                }catch{
                    print("Error writing file: \(error)")
                }
                
                
            }
        }
        
        do{
            try managedObjectContext.save()
            afterDelay(0.6) {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
            
        }catch{
            fatalCoreDataError(error)
        }
        
    }
    @IBAction func cancel() {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @objc func hideKeyboard(){
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0{
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    func show(_ image: UIImage){
        imageView.image = image
        imageView.isHidden = false
        imageHeight.constant = 220
        addPhotoLabel.text = ""
        tableView.reloadData()
        
    }
    
    func listenForBackgroundNotification(){
        observer = NotificationCenter.default.addObserver(forName: UIScene.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            if let self = self{
                if self.presentedViewController != nil{
                    self.dismiss(animated: true, completion: nil)
                }
                self.descriptionTextView.resignFirstResponder()
            }
        }
    }
    
    
}

//extension LocationDetailsViewController: CategoryPickerViewControllerDelegate{
//    func pickCategory(_ controller: CategoryPickerViewController, for category: String) {
//        self.category = category
//        categoryLabel.text = category
//        navigationController?.popViewController(animated: true)
//    }
//
//
//}

//MARK: - Unwind Segue
extension LocationDetailsViewController{
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue){
        let controller = segue.source as! CategoryPickerViewController
        category = controller.selectedCategory
        categoryLabel.text = controller.selectedCategory
    }
}


extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pickPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            showPhotoMenu()
        }else{
            choosePhotoFromLibrary()
        }
    }
    
    
    func showPhotoMenu(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let actionPhoto = UIAlertAction(title: "Take Photo", style: .default){_ in self.takePhotoWithCamera()}
        let actionchooseFromLibrary = UIAlertAction(title: "Choose From Library", style: .default){_ in self.choosePhotoFromLibrary()}
        alert.addAction(actionCancel)
        alert.addAction(actionPhoto)
        alert.addAction(actionchooseFromLibrary)
        present(alert, animated: true, completion: nil)
        
    }
    
    func takePhotoWithCamera(){
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        image = info[UIImagePickerController.InfoKey.editedImage] as?  UIImage
        
        if let image = image{
            show(image)
           
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary(){
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}
