//
//  MelkDetailAttachmentTableViewController.swift
//  AmlakApp
//
//  Created by nader on 6/31/1402 AP.
//

import UIKit
import CoreData
class MelkDetailAttachmentDataManager {
    static let shared = MelkDetailAttachmentDataManager()

    private var melkDetailAttachmentDataRequests: [String: Bool] = [:]

    private init() {}

    func isRequestInProgress(forGroupId groupId: Int, forCategoryId categoryId: Int) -> Bool {
        let requestKey = "\(groupId)-\(categoryId)"
        return melkDetailAttachmentDataRequests[requestKey] != nil
    }

    func markRequestInProgress(forGroupId groupId: Int, forCategoryId categoryId: Int) {
        let requestKey = "\(groupId)-\(categoryId)"
        melkDetailAttachmentDataRequests[requestKey] = true
    }

    func markRequestAsCompleted(forGroupId groupId: Int, forCategoryId categoryId: Int) {
        let requestKey = "\(groupId)-\(categoryId)"
        melkDetailAttachmentDataRequests[requestKey] = nil
    }
}

class MelkDetailAttachmentViewController: UIViewController {
    
    // MARK: - Properties
    
    private var fetchedResultsController: NSFetchedResultsController<MelkDetailAttachmentEntity>!
    private var searchActive: Bool = false

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    var melk: MelkEntity?
    var melkDetail: MelkDetailEntity?
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        setupFetchedResultsController()
        
        // Additional setup if needed
        
        tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = UITableView.automaticDimension
        var radifText = ""
        if let radif = melkDetail?.radif {
            radifText = "\(radif)"
            if let radif2 = melkDetail?.radif2, radif2 > 0 {
                radifText += "/\(radif2)"
            }
        }
        
        title = "\(melk!.name ?? "ثبت نشده") | پرونده: \(melk!.parvandeh) | شماره پلاک: \(melk!.shamarehPelakSabti ?? "ثبت نشده") | ردیف: \(radifText)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchDataFromAPI()
    }
    
    // MARK: - Private Methods
    
    private func setupFetchedResultsController() {
        attemptFetch(inputTxt: "")
    }
    
    private func fetchDataFromAPI() {
        
        getMelkDetailAttachmentsData(melkId: Int(melkDetail!.melkId)) { [weak self] attachments, error in
            if let error = error {
                print("Error getting melks data: \(error)")
            } else if let attachments = attachments {
                // Handle retrieved categories data if needed
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func attemptFetch(inputTxt: String) {
        var cleanedSearchText = clearFarsiText(inputText: inputTxt)
        
        let fetchRequest: NSFetchRequest<MelkDetailAttachmentEntity> = MelkDetailAttachmentEntity.fetchRequest()
        let creationTimeSort = NSSortDescriptor(key: "fileName", ascending: true)
        fetchRequest.sortDescriptors = [creationTimeSort]
        let predicateMelkId = NSPredicate(format: "melkDetailId == %d", melkDetail!.melkId)
        
        var predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [predicateMelkId])
        if !cleanedSearchText.isEmpty {
            let predicateSearch = NSPredicate(format: "fileName CONTAINS[cd] %@", cleanedSearchText)
            predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [predicateMelkId, predicateSearch])
        }
        
        fetchRequest.predicate = predicateCompound
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        fetchedResultsController = controller
        
        do {
            try controller.performFetch()
            tableView.reloadData()
        } catch {
            let error = error as NSError
            print("\(error)")
        }
        
    }
    
    // MARK: - Actions
    
    // Your action methods go here if needed
    
    // MARK: - Other methods if needed
    
    // ...
}

// MARK: - UITableViewDelegate & UITableViewDataSource Extension

extension MelkDetailAttachmentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MelkDetailAttachmentTableViewCell
        cell.configureCell(input: fetchedResultsController.object(at: indexPath))
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "showAttachment",
            let destination = segue.destination as? AttachmentViewController,
            let indexPath = tableView.indexPathForSelectedRow
        {
            destination.melkDetailAttachment = fetchedResultsController.object(at: indexPath)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate Extension

extension MelkDetailAttachmentViewController: NSFetchedResultsControllerDelegate {
    // MARK: - NSFetchedResultsControllerDelegate Methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
}

// MARK: - UISearchBarDelegate Extension

extension MelkDetailAttachmentViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            // Call the attemptFetch method to perform a search
            attemptFetch(inputTxt: searchText)
        }
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Clear the search bar and dismiss the keyboard
        searchBar.text = ""
        searchBar.resignFirstResponder()

        // Reset the fetch to show all data
        attemptFetch(inputTxt: "")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Perform live search updates as the user types
        attemptFetch(inputTxt: searchText)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Handle any specific behavior when the search bar begins editing
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Handle any specific behavior when the search bar ends editing
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // Handle scope button changes if you have a scope bar
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // Return true or false based on whether the search bar should begin editing
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        // Return true or false based on whether the search bar should end editing
        return true
    }
}
