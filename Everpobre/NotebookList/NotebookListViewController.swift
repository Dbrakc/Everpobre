//
//  NotebookListViewController.swift
//  Everpobre
//
//  Created by Charles Moncada on 08/10/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit
import CoreData

class NotebookListViewController: UIViewController {

	// MARK: IBOutlets
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var totalLabel: UILabel!

	// MARK: Parameters

//	var managedContext: NSManagedObjectContext! // Beware to have a value before presenting the VC
	var coredataStack: CoreDataStack!

//	var model: [deprecated_Notebook] = [] {
//		didSet {
//			tableView.reloadData()
//		}
//	}

//	var dataSource: [NSManagedObject] = [] {
//		didSet {
//			tableView.reloadData()
//		}
//	}

	private var fetchedResultsController: NSFetchedResultsController<Notebook>!

//	{
//		do {
//			return try managedContext.fetch(Notebook.fetchRequest())
//		} catch let error as NSError {
//			print(error.localizedDescription)
//			return []
//		}
//	}

	// MARK: Lifecycle

	override func viewDidLoad() {
		//model = deprecated_Notebook.dummyNotebookModel
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        
		
		super.viewDidLoad()

		configureSearchController()
		showAll()
        
        let exportButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportCSVs))
        let addNotebookItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNotebook(_:)))
        
        self.navigationItem.rightBarButtonItems = [exportButtonItem, addNotebookItem]
       
        
		//reloadView()
	}
    
//    @objc private func exportCSV() {
//
//        coredataStack!.storeContainer.performBackgroundTask { [unowned self] context in
//
//            let results: [Note] = self.getNotesArray()
//
//            let exportPath = NSTemporaryDirectory() + "export.csv"
//            let exportURL = URL(fileURLWithPath: exportPath)
//            FileManager.default.createFile(atPath: exportPath, contents: Data(), attributes: nil)
//
//            self.writeAndExportCsv(exportURL: exportURL, objectToWrite : results, exportPath: exportPath){_ in
//                DispatchQueue.main.async { [weak self] in
//                    self?.showExportFinishedAlert(exportPath)
//                }
//            }
//        }
//
//    }
    @objc private func exportCSVs (){
        coredataStack!.storeContainer.performBackgroundTask { [unowned self] context in
            let notebooks = self.fetchedResultsController.fetchedObjects?.compactMap{ return $0 }
        
            notebooks?.forEach{self.writeAndExportCsv(notebookToWrite: $0 )}
            DispatchQueue.main.async { [weak self] in
                self?.showExportFinishedAlert()
            }
                
        }
            
    }
    
    private func showExportFinishedAlert() {
        let message = "Los archivos CSV se encuentra en \(NSTemporaryDirectory())"
        let alertController = UIAlertController(title: "Exportacion terminada", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }

        
    
        
        
    
    
    fileprivate func writeAndExportCsv(notebookToWrite notebook: Notebook){
        let name = notebook.name!
        let exportPath = NSTemporaryDirectory() + "/\(name).csv"
        let exportURL = URL(fileURLWithPath: exportPath)
        FileManager.default.createFile(atPath: exportPath, contents: Data(), attributes: nil)
        let fileHandle: FileHandle?
        do {
            fileHandle = try FileHandle(forWritingTo: exportURL)
        } catch let error as NSError {
            print(error.localizedDescription)
            fileHandle = nil
        }
        
        if let fileHandle = fileHandle {
            for note  in notebook.notes!.array as! [Note]  {
                fileHandle.seekToEndOfFile()
                
                guard let csvData = note.csv().data(using: .utf8, allowLossyConversion: false) else { return  }
                fileHandle.write(csvData)
            }
            
            fileHandle.closeFile()
           
            
            
        } else {
            print("no podemos exportar la data")
          
        }
    }

	// MARK: NSFetchedResultsController helper methods

	private func getFetchedResultsController(with predicate: NSPredicate = NSPredicate(value: true)) -> NSFetchedResultsController<Notebook> {

		let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
		fetchRequest.predicate = predicate

		let sort = NSSortDescriptor(key: #keyPath(Notebook.creationDate), ascending: true)
		fetchRequest.sortDescriptors = [sort]

		fetchRequest.fetchBatchSize = 20

		return NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: coredataStack.managedContext,
			sectionNameKeyPath: #keyPath(Notebook.creationDate),
			cacheName: nil)
	}

	private func setNewFetchedResultsController(_ newfrc: NSFetchedResultsController<Notebook>) {

		let oldfrc = fetchedResultsController
		if (newfrc != oldfrc) {
			fetchedResultsController = newfrc
			newfrc.delegate = self
			do {
				try fetchedResultsController.performFetch()
			} catch let error as NSError {
				print("COuld not fetch \(error)")
			}
			tableView.reloadData()
		}
	}

	// MARK: Helper methods

	private func configureSearchController() {
		let search = UISearchController(searchResultsController: nil)
		search.searchResultsUpdater = self
		search.obscuresBackgroundDuringPresentation = false
		search.searchBar.placeholder = "Search Notebook"
		navigationItem.searchController = search
		navigationItem.hidesSearchBarWhenScrolling = true
		definesPresentationContext = true
	}

//	private func reloadView() {
//
//		do {
//			dataSource = try managedContext.fetch(Notebook.fetchRequest())
//		} catch let error as NSError {
//			print(error.localizedDescription)
//			dataSource = []
//		}
//
//		populateTotalLabel()
//		tableView.reloadData()
//	}

	private func populateTotalLabel(with predicate: NSPredicate = NSPredicate(value: true)) {
		let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Notebook")
		fetchRequest.resultType = .countResultType

		fetchRequest.predicate = predicate

		do {
			let countResult = try coredataStack.managedContext.fetch(fetchRequest)
			let count = countResult.first!.intValue
			totalLabel.text = "\(count)"
		} catch let error as NSError {
			print("Count not fetch: \(error.description)")
		}

	}
	
	@IBAction func addNotebook(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Nuevo Notebook", message: "Añade un nuevo Notebbok", preferredStyle: .alert)

		let saveAction = UIAlertAction(title: "Grabar", style: .default) { [unowned self] action in
			guard
				let textField = alert.textFields?.first,
				let nameToSave = textField.text
			else { return }

			let notebook = Notebook(context: self.coredataStack.managedContext)
			notebook.name = nameToSave
			notebook.creationDate = NSDate()

			do {
				try self.coredataStack.managedContext.save()
			} catch let error as NSError {
				print("TODO Error handling: \(error.debugDescription)")
			}

			//self.tableView.reloadData()
			//self.reloadView()
			self.showAll()
		}

		let cancelAction = UIAlertAction(title: "Cancelar", style: .default)

		alert.addTextField()
		alert.addAction(saveAction)
		alert.addAction(cancelAction)

		present(alert, animated: true)
	}
}

// MARK:- UITableViewDataSource implementation

extension NotebookListViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		guard let section = fetchedResultsController.sections else { return 1 }
		return section.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
		return sectionInfo.numberOfObjects
		//return dataSource.count//model.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "NotebookListCell", for: indexPath) as! NotebookListCell
		//let notebook = dataSource[indexPath.row] as! Notebook
		let notebook = fetchedResultsController.object(at: indexPath)

		//cell.configure(with: model[indexPath.row])
		cell.configure(with: notebook)

		return cell
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//		guard
//			let notebookToRemove = dataSource[indexPath.row] as? Notebook,
//			editingStyle == .delete
//		else { return }
		guard editingStyle == .delete else { return }

		let notebookToRemove = fetchedResultsController.object(at: indexPath)

		coredataStack.managedContext.delete(notebookToRemove)

		do {
			try coredataStack.managedContext.save()
			//tableView.deleteRows(at: [indexPath], with: .automatic)
		} catch let error as NSError {
			print("error: \(error.localizedDescription)")
		}

		//tableView.reloadData()
		//reloadView()
		showAll()
	}

}

// MARK:- UITableViewDelegate implementation

extension NotebookListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		let notebook = model[indexPath.row]
//		let notesListVC = NotesListViewController(notebook: notebook)
//		show(notesListVC, sender: nil)

		//let notebook = dataSource[indexPath.row] as! Notebook
		let notebook = fetchedResultsController.object(at: indexPath)

		//let notesListVC = NotesListViewController(notebook: notebook, managedContext: managedContext)
        let tabBarController = UITabBarController()
		
        let mapViewContoller = MapViewController(notebook: notebook, coreDataStack: coredataStack)
        let notesListVC = NewNotesListViewController(notebook: notebook, coreDataStack: coredataStack,delegate: mapViewContoller)
        tabBarController.viewControllers = [notesListVC.wrappedInNavigation(), mapViewContoller.wrappedInNavigation()]
		show(tabBarController, sender: nil)
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sectionInfo = fetchedResultsController.sections?[section]
		return sectionInfo?.name
	}
}

// MARK:- UISearchResultsUpdating implmentation

extension NotebookListViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		if let text = searchController.searchBar.text, !text.isEmpty {
			//mostramos resultados filtrados
			showFilteredResults(with: text)
		} else {
			// Mostramos todos los resultadosas
			showAll()
		}
	}

	private func showFilteredResults(with query: String) {
//		let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
//		fetchRequest.resultType = .managedObjectResultType
//
//		let predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
//		fetchRequest.predicate = predicate
//
//		do {
//			dataSource = try managedContext.fetch(Notebook.fetchRequest())
//		} catch let error as NSError {
//			print("COuld not fetch \(error)")
//			dataSource = []
//		}
//
//		populateTotalLabel(with: predicate)

		let predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
		let frc = getFetchedResultsController(with: predicate)
		setNewFetchedResultsController(frc)

		populateTotalLabel(with: predicate)

	}

	private func showAll() {

//		let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: Notebook.fetchRequest()) { [weak self] (result) in
//
//			guard let notebooks = result.finalResult else {
//				self?.dataSource = []
//				return
//			}
//			self?.dataSource = notebooks
//		}
//
//		do {
//			//dataSource = try managedContext.fetch(Notebook.fetchRequest())
//			try managedContext.execute(asyncFetchRequest)
//		} catch let error as NSError {
//			print("COuld not fetch \(error)")
//			dataSource = []
//		}

		let frc = getFetchedResultsController()
		setNewFetchedResultsController(frc)
		//fetchedResultsController.delegate = self

		do {
			try fetchedResultsController.performFetch()
		} catch let error as NSError {
			print("COuld not fetch \(error)")
			//dataSource = []
		}

		populateTotalLabel()
	}
}

// MARK:- NSFetchedResultsControllerDelegate implementation

extension NotebookListViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			tableView.insertRows(at: [newIndexPath!], with: .automatic)
		case .delete:
			tableView.deleteRows(at: [indexPath!], with: .automatic)
		default:
			break
		}
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

		let indexSet = IndexSet(integer: sectionIndex)
		switch type {
		case .insert:
			tableView.insertSections(indexSet, with: .automatic)
		case .delete:
			tableView.deleteSections(indexSet, with: .automatic)
		default:
			break
		}
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
}


