//
//  NewNotesListViewController.swift
//  Everpobre
//
//  Created by Charles Moncada on 11/10/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit
import CoreData

class NewNotesListViewController: UIViewController {

	@IBOutlet weak var collectionView: UICollectionView!

	let notebook: Notebook
	let managedContext: NSManagedObjectContext

	var notes: [Note] = [] {
		didSet {
			self.collectionView.reloadData()
		}
	}

	init(notebook: Notebook, managedContext: NSManagedObjectContext) {
		self.notebook = notebook
		self.notes = (notebook.notes?.array as? [Note]) ?? []
		self.managedContext = managedContext
		super.init(nibName: "NewNotesListViewController", bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Notas"
		self.view.backgroundColor = .white

		let nib = UINib(nibName: "NotesListCollectionViewCell", bundle: nil)
		collectionView.register(nib, forCellWithReuseIdentifier: "NotesListCollectionViewCell")

		collectionView.backgroundColor = .lightGray

		let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
		self.navigationItem.rightBarButtonItem = addButtonItem
	}

	@objc private func addNote() {
		let newNoteVC = NoteDetailsViewController(kind: .new(notebook: notebook), managedContext: managedContext)
		newNoteVC.delegate = self
		let navVC = UINavigationController(rootViewController: newNoteVC)
		self.present(navVC, animated: true, completion: nil)
	}

}

extension NewNotesListViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return notes.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesListCollectionViewCell", for: indexPath) as! NotesListCollectionViewCell
		cell.configure(with: notes[indexPath.row])
		return cell
	}

}

extension NewNotesListViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let detailVC = NoteDetailsViewController(kind: .existing(note: notes[indexPath.row]), managedContext: managedContext)
		detailVC.delegate = self
		self.show(detailVC, sender: nil)
	}
}

extension NewNotesListViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 100, height: 150)
	}
}

extension NewNotesListViewController: NoteDetailsViewControllerProtocol {
	func didSaveNote() {
		self.notes = (notebook.notes?.array as? [Note]) ?? []
	}
}
