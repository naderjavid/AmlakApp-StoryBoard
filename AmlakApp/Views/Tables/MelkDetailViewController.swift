//
//  MelkDetailTableViewController.swift
//  AmlakApp
//
//  Created by nader on 6/31/1402 AP.
//

import UIKit
import CoreData
class MelkDetailDataManager {
    static let shared = MelkDetailDataManager()

    private var melkDetailDataRequests: [String: Bool] = [:]

    private init() {}

    func isRequestInProgress(forGroupId groupId: Int, forMelkDetailId categoryId: Int) -> Bool {
        let requestKey = "\(groupId)-\(categoryId)"
        return melkDetailDataRequests[requestKey] != nil
    }

    func markRequestInProgress(forGroupId groupId: Int, forMelkDetailId categoryId: Int) {
        let requestKey = "\(groupId)-\(categoryId)"
        melkDetailDataRequests[requestKey] = true
    }

    func markRequestAsCompleted(forGroupId groupId: Int, forMelkDetailId categoryId: Int) {
        let requestKey = "\(groupId)-\(categoryId)"
        melkDetailDataRequests[requestKey] = nil
    }
}

class MelkDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private var fetchedResultsController: NSFetchedResultsController<MelkDetailEntity>!
    private var searchActive: Bool = false

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    var melk: MelkEntity?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        setupFetchedResultsController()
        
        // Additional setup if needed
        
        tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = UITableView.automaticDimension
        
        title = "\(melk!.name ?? "ثبت نشده") | پرونده: \(melk!.parvandeh) | شماره پلاک: \(melk!.shamarehPelakSabti ?? "ثبت نشده")"
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
        
        getMelkDetailsData(parvandeh: Int(melk!.parvandeh)) { [weak self] melkDetails, error in
            if let error = error {
                print("Error getting melks data: \(error)")
            } else if let melkDetails = melkDetails {
                // Handle retrieved categories data if needed
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        
    }

    func attemptFetch(inputTxt: String) {
        let cleanedSearchText = clearFarsiText(inputText: inputTxt)
        
        let fetchRequest: NSFetchRequest<MelkDetailEntity> = MelkDetailEntity.fetchRequest()
        let radifSort = NSSortDescriptor(key: "radif", ascending: true)
        let radif2Sort = NSSortDescriptor(key: "radif", ascending: true)
        fetchRequest.sortDescriptors = [radifSort, radif2Sort]
        
        let predicateParvandeh = NSPredicate(format: "parvandeh == %d", melk!.parvandeh)
        var predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [predicateParvandeh])
        
        if !cleanedSearchText.isEmpty {
            let predicateSearch = NSPredicate(format: "sharh CONTAINS[cd] %@", cleanedSearchText)
            predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [predicateParvandeh, predicateSearch])
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

extension MelkDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MelkDetailTableViewCell
        cell.configureCell(input: fetchedResultsController.object(at: indexPath))
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "showMelkDetailAttachment",
            let destination = segue.destination as? MelkDetailAttachmentViewController,
            let indexPath = tableView.indexPathForSelectedRow
        {
            destination.melk = melk
            destination.melkDetail = fetchedResultsController.object(at: indexPath)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate Extension

extension MelkDetailViewController: NSFetchedResultsControllerDelegate {
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

extension MelkDetailViewController: UISearchBarDelegate {
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
