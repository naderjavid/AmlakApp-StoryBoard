//
//  MelkTableViewController.swift
//  AmlakApp
//
//  Created by nader on 6/31/1402 AP.
//

import UIKit
import CoreData
class MelkDataManager {
    static let shared = MelkDataManager()

    private var melkDataRequests: [String: Bool] = [:]

    private init() {}

    func isRequestInProgress(forParvandeh parvandeh: Int) -> Bool {
        let requestKey = "\(parvandeh)"
        return melkDataRequests[requestKey] != nil
    }

    func markRequestInProgress(forParvandeh parvandeh: Int) {
        let requestKey = "\(parvandeh)"
        melkDataRequests[requestKey] = true
    }

    func markRequestAsCompleted(forParvandeh parvandeh: Int) {
        let requestKey = "\(parvandeh)"
        melkDataRequests[requestKey] = nil
    }
}

class MelkViewController: UIViewController {
    
    // MARK: - Properties
    
    private var fetchedResultsController: NSFetchedResultsController<MelkEntity>!
    private var searchActive: Bool = false

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        setupFetchedResultsController()
        
        // Additional setup if needed
        
        tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = UITableView.automaticDimension
        
        //title = category?.title
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
//        getMelkDetailAttachmentsData { [weak self] attachments, error in
//            if let error = error {
//                print("Error getting melks data: \(error)")
//            } else if let attachments = attachments {
//                // Handle retrieved categories data if needed
//                DispatchQueue.main.async {
//                    print("attachments count \(getMelkDetailAttachmentCount())")
//                    self?.tableView.reloadData()
//                }
//            }
//        }
        
        getMelksData { [weak self] melks, error in
            if let error = error {
                print("Error getting melks data: \(error)")
            } else if let melks = melks {
                // Handle retrieved categories data if needed
//                
//                for melk in melks {
//                    getMelkDetailsData(parvandeh: melk.parvandeh) { details, error in
//                        
//                    }
//                    
//                }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func attemptFetch(inputTxt: String) {
        let cleanedSearchText = clearFarsiText(inputText: inputTxt)
        
        let fetchRequest: NSFetchRequest<MelkEntity> = MelkEntity.fetchRequest()
        let parvandehSort = NSSortDescriptor(key: "parvandeh", ascending: true)
        fetchRequest.sortDescriptors = [parvandehSort]
        
        if cleanedSearchText != "" {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", cleanedSearchText)
        }
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        controller.delegate = self
        
        self.fetchedResultsController = controller
        
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

extension MelkViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MelkTableViewCell
        cell.configureCell(input: fetchedResultsController.object(at: indexPath))
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "showMelkDetail",
            let destination = segue.destination as? MelkDetailViewController,
            let indexPath = tableView.indexPathForSelectedRow
        {
            destination.melk = fetchedResultsController.object(at: indexPath)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate Extension

extension MelkViewController: NSFetchedResultsControllerDelegate {
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

extension MelkViewController: UISearchBarDelegate {
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
