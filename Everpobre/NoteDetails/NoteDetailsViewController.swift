//
//  NoteDetailsViewController.swift
//  Everpobre
//
//  Created by Charles Moncada on 08/10/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

// MARK:- NoteDetailsViewControllerProtocol

protocol NoteDetailsViewControllerProtocol: class {
	func didSaveNote()
}

// MARK:- NoteDetailsViewController class

class NoteDetailsViewController: UIViewController {

	enum Kind {
		case new(notebook: Notebook)
		case existing(note: Note)
	}

	// MARK: IBOutlets
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var titleTextField: UITextField!
   
    @IBOutlet weak var pickerView: UIPickerView!
    
	@IBOutlet weak var creationDateLabel: UILabel!
	@IBOutlet weak var lastSeenDateLabel: UILabel!
	@IBOutlet weak var descriptionTextView: UITextView!

	// MARK: Parameters

//	let note: Note
	let managedContext: NSManagedObjectContext
	let kind: Kind
    let locationManager = CLLocationManager ()
    var lastLocation : CLLocation?
    private let tagsDataList: [Note.Tag] = [.Info,.Personal,.Todo,.Otros]
    var pickerData: [String]{
        return tagsDataList.map{$0.rawValue}
    }
    var selectedPickerRow : String?

	weak var delegate: NoteDetailsViewControllerProtocol?

	// MARK: Init

	init(kind: Kind, managedContext: NSManagedObjectContext) {
		self.kind = kind
		self.managedContext = managedContext
		super.init(nibName: "NoteDetailsViewController", bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
		configure()
        switch kind {
        case .new(_):
            setLocationRequestLoop()
        default:
            break;
        }
        
    }
    
    func setLocationRequestLoop () {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        let delay = DispatchTime.now() + .seconds(5)
        let queue = DispatchQueue(label: "locationLoop")
        queue.asyncAfter(deadline: delay, execute: {
            while(true){
                if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    DispatchQueue.main.async {
                        self.locationManager.requestLocation()
                    }
                    
                }
            }
        })
        
    }

	// MARK: IBAction

	@IBAction private func pickImage(_ sender: UIButton) {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			showPhotoMenu()
		} else {
			choosePhotoFromLibrary()
		}
	}

	// MARK: Helper methods

	private func configure() {
		let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote))
		self.navigationItem.rightBarButtonItem = saveButtonItem
		let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
		self.navigationItem.leftBarButtonItem = cancelButtonItem

		title = kind.title
		titleTextField.text = kind.note?.title
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.selectRow(pickerData.lastIndex(of: kind.note?.tags ?? Note.Tag.Todo.rawValue)!, inComponent: 0, animated: true)
		creationDateLabel.text = "Creado: \((kind.note?.creationDate as Date?)?.customStringLabel() ?? "ND")"
		lastSeenDateLabel.text = "Visto: \((kind.note?.lastSeenDate as Date?)?.customStringLabel() ?? "ND")"
		descriptionTextView.text = kind.note?.text ?? "Ingrese texto..."

		guard let data = kind.note?.image as Data? else {
			imageView.image = #imageLiteral(resourceName: "120x180.png")
			return
		}

		imageView.image = UIImage(data: data)
        
        
	}

	@objc private func saveNote() {
        
        func setCoordinates (in note: Note) {
            let coordinates = Coodinates(context: managedContext)
            guard lastLocation != nil else{
                return
            }
            coordinates.latitude = lastLocation!.coordinate.latitude
            coordinates.longitude = lastLocation!.coordinate.longitude
            coordinates.addToNotes(note)
           
        }

		func addProperties(to note: Note) -> Note {
			note.title = titleTextField.text
			note.text = descriptionTextView.text
            note.tags = selectedPickerRow

			let imageData: NSData?
            if imageView.image == #imageLiteral(resourceName: "120x180.png"),
                let data = #imageLiteral(resourceName: "stickyNote.jpg").pngData(){
                imageData = NSData(data: data)
            } else if imageView.image != #imageLiteral(resourceName: "120x180.png"), let image = imageView.image,
				let data = image.pngData() {
				imageData = NSData(data: data)
			} else { imageData = nil }
			note.image = imageData

			return note
		}

		switch kind {
		case .existing(let note):
			let modifiedNote = addProperties(to: note)
			modifiedNote.lastSeenDate = NSDate()

		case .new(let notebook):
			let note = Note(context: managedContext)
            if(lastLocation != nil){
                setCoordinates(in: note)
            }
			let modifiedNote = addProperties(to: note)
			modifiedNote.creationDate = NSDate()
			modifiedNote.notebook = notebook

			if let notes = notebook.notes?.mutableCopy() as? NSMutableOrderedSet {
				notes.add(note)
				notebook.notes = notes
			}
		}

		do {
			try managedContext.save()
			delegate?.didSaveNote()
		} catch let error as NSError {
			print("error: \(error.localizedDescription)")
		}

		dismiss(animated: true, completion: nil)

	}

	@objc private func cancel() {
		dismiss(animated: true, completion: nil)
	}
}

// MARK:- UIImagePickerControllerDelegate & related methods

extension NoteDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

		func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
			return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
		}

		func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
			return input.rawValue
		}

		let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

		let rawImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage

		let imageSize = CGSize(width: self.imageView.bounds.width * UIScreen.main.scale, height: self.imageView.bounds.height * UIScreen.main.scale)

		DispatchQueue.global(qos: .default).async {
			let image = rawImage?.resizedImageWithContentMode(.scaleAspectFill, bounds: imageSize, interpolationQuality: .high)

			DispatchQueue.main.async {
				if let image = image {
					self.imageView.contentMode = .scaleAspectFill
					self.imageView.clipsToBounds = true
					self.imageView.image = image
				}
			}
		}

		dismiss(animated: true, completion: nil)
	}

	private func showPhotoMenu() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera() })
		let chooseFromLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibrary() })

		alertController.addAction(cancelAction)
		alertController.addAction(takePhotoAction)
		alertController.addAction(chooseFromLibrary)

		present(alertController, animated: true, completion: nil)
	}

	private func choosePhotoFromLibrary() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .photoLibrary
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		present(imagePicker, animated: true, completion: nil)
	}

	private func takePhotoWithCamera() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .camera
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		present(imagePicker, animated: true, completion: nil)
	}
}

// MARK:- NoteDetailsViewController.Kind extension

private extension NoteDetailsViewController.Kind {
	var note: Note? {
		guard case let .existing(note) = self else { return nil }
		return note
	}

	var title: String {
		switch self {
		case .existing:
			return "Detalle"
		case .new:
			return "Nueva Nota"
		}
	}
}

extension NoteDetailsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lastLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("No pude conseguir la ubicacion del usuario: \(error.localizedDescription)")
    }
}

extension NoteDetailsViewController : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

}

extension NoteDetailsViewController : UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerRow = pickerData[row]
    }
    
}


