//
//  ShoppingRegisterViewController.swift
//  ComprasUSA
//
//  Created by Fellipe Soares Oliveira on 21/04/2018.
//  Copyright © 2018 Fellipe Soares Oliveira. All rights reserved.
//

import UIKit
import CoreData

class ShoppingRegisterViewController: UIViewController {
    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var btRegister: UIButton!
    @IBOutlet weak var swPaymentForm: UISwitch!
    @IBOutlet weak var lbPrice: UITextField!
    @IBOutlet weak var lbName: UITextField!
    @IBOutlet weak var lbShoppingState: UITextField!
    @IBOutlet weak var btAddUpdate: UIButton!
    
    // MARK: - Properties
    var product: Product!
    var smallImage: UIImage!
    var pickerView: UIPickerView!
    var fetchedResultController: NSFetchedResultsController<State>!
    var dataSource: [State]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if product != nil {
            lbName.text = product.name
            lbPrice.text = "\(product.price)"
            swPaymentForm.isOn = product.paymentForm
            btAddUpdate.setTitle("Atualizar", for: .normal)
            if let image = product.photo as? UIImage {
                ivPhoto.image = image
            }
        }
        
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        lbShoppingState.inputAccessoryView = toolbar
        lbShoppingState.inputView = pickerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadStates()
        if let product = product {
            lbShoppingState.text = product.state?.name
        }
    }
    
    // MARK:  Methods
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
            dataSource = fetchedResultController!.fetchedObjects!
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func cancel() {
        lbShoppingState.resignFirstResponder()
    }
    
    @objc func done() {
        if let data = dataSource, data.count > 0 {
           if let name = data[pickerView.selectedRow(inComponent: 0)].name {
               lbShoppingState.text = name
           }
        }
        cancel()
    }
    
    // MARK: - IBActions
    @IBAction func addPoster(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecionar Imagem", message: "De onde você quer escolher a imagem?", preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }

        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)

        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)

        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    
    func close () { navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addUpdateProduct(_ sender: UIButton) {
        if product == nil {
            product = Product(context: context)
        }
        product.name = lbName.text!
        product.price = Double(lbPrice.text!)!
        product.paymentForm = swPaymentForm.isOn
        
        var state: State!
        
        dataSource?.forEach({ (s) in
            if s.name!.elementsEqual(lbShoppingState.text!) {
                state = s
            }
        })
        
        product.state = state
        if smallImage != nil {
            product.photo = smallImage
        }
        do {
            try context.save()
            self.navigationController?.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
        close()
    }

}

// MARK: - UIImagePickerControllerDelegate
extension ShoppingRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        ivPhoto.image = smallImage
        dismiss(animated: true, completion: nil)
    }
}

extension ShoppingRegisterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fetchedResultController.object(at: IndexPath(row: row, section: 0)).name
    }
}

extension ShoppingRegisterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = 0
        if let data = dataSource, data.count > 0 {
            count = data.count
        }
        return count
    }
}

extension ShoppingRegisterViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}
