//
//  EventFormVC.swift
//  FirebaseAssessment
//
//  Created by Dev on 7/13/17.
//  Copyright © 2017 Colin. All rights reserved.
//

import UIKit
import PKHUD

class EventFormVC: UIViewController {

    @IBOutlet weak var m_imgImage: UIImageView!
    
    @IBOutlet weak var m_txtName: UITextField!
    
    @IBOutlet weak var m_txtPrice: UITextField!
    
    @IBOutlet weak var m_txtAddress: UITextField!
    
    @IBOutlet weak var m_datePicker: UIDatePicker!
    
    @IBOutlet weak var m_btnAddEdit: UIButton!
    
    @IBOutlet weak var m_btnRemove: UIButton!
    
    @IBOutlet weak var m_navTitle: UINavigationItem!
    
    let picker = UIImagePickerController()
    
    var m_event: Event?
    var newImage: UIImage?
    var imageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let event = m_event {
            if let url = URL(string:event.Image) {
                m_imgImage.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                m_btnAddEdit.setTitle("Change Image", for: .normal)
                m_btnRemove.isHidden = false
            } else {
                m_btnAddEdit.setTitle("Set Image", for: .normal)
                m_btnRemove.isHidden = true
            }
            
            m_txtName.text = event.Name
            m_txtPrice.text = "\(event.Price)"
            m_txtAddress.text = "\(event.Address)"
            m_datePicker.date = Date(timeIntervalSince1970: event.Date / 1000)
            m_navTitle.title = "Edit Event"
            
            imageURL = event.Image
        } else {
            m_navTitle.title = "New Event"
            m_btnAddEdit.setTitle("Set Image", for: .normal)
            m_btnRemove.isHidden = true
        }
        picker.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickRemoveImage(_ sender: Any) {
        self.m_imgImage.image = UIImage(named: "placeholder")
        self.m_btnRemove.isHidden = false
        self.m_btnAddEdit.setTitle("Set Image", for: .normal)
        
        self.newImage = nil
        self.imageURL = ""
        self.m_btnRemove.isHidden = true
    }

    @IBAction func onClickSetImage(_ sender: Any) {
        // From Library
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    @IBAction func onClickSave(_ sender: Any) {
        var error = false
        if (m_txtName.text! == "") {
            animateInvalidTextBox(txtField: self.m_txtName)
            error = true
        }
        
        if let price = Int(m_txtPrice.text!) {
            if (price < 0) {
                animateInvalidTextBox(txtField: self.m_txtPrice)
                error = true
            }
        } else {
            animateInvalidTextBox(txtField: self.m_txtPrice)
            error = true
        }
        
        
        if (m_txtAddress.text! == "") {
            animateInvalidTextBox(txtField: self.m_txtAddress)
            error = true
        }
        
        if (error) {
            return
        }
        
        
        let event = Event(name: m_txtName.text!, date: m_datePicker.date.timeIntervalSince1970 * 1000, price: Int(m_txtPrice.text!)!, address: m_txtAddress.text!, image: imageURL, created: Date().timeIntervalSince1970 * 1000)
        
        if (self.m_event != nil) {
            event.ID = self.m_event!.ID
        } else {
            event.ID = Store.newEventKey()
        }
        
        HUD.show(.labeledProgress(title: "", subtitle: "Saving..."))
        
        if let image = self.newImage { // No Image
            Store.saveImage(id: event.ID, image: image, callback: {(savedImageUrl) in
                if let url = savedImageUrl?.absoluteString {
                    event.Image = url
                    self.newImage = nil
                    self.imageURL = url
                    
                    Store.saveEvent(event: event, isNew: self.m_event == nil) { (_event) in
                        
                        if let updatedEvent = _event {
                            DispatchQueue.main.async {
                                HUD.hide()
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            DispatchQueue.main.async {
                                HUD.hide()
                                HUD.show(.labeledError(title: "", subtitle: "Failed to upload image"))
                            }
                        }
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        HUD.hide()
                        HUD.show(.labeledError(title: "", subtitle: "Failed to upload image"))
                    }
                }
            })
        } else {
            Store.saveEvent(event: event, isNew: self.m_event == nil) { (savedEvent) in
                DispatchQueue.main.async {
                    HUD.hide()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    

    func animateInvalidTextBox(txtField: UITextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: txtField.center.x - 10, y: txtField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: txtField.center.x + 10, y: txtField.center.y))
        txtField.layer.add(animation, forKey: "position")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EventFormVC: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.newImage = image
            self.m_imgImage.image = self.newImage
            self.imageURL = ""
            self.m_btnRemove.isHidden = false
        } else {
            HUD.show(.labeledError(title: "", subtitle: "Invalid Image"))
        }
        
        picker.dismiss(animated: true, completion: nil)
     
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}
