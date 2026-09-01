import CoreData
import UIKit

// MARK: - Delegate Protocol
protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidChange(_ store: TrackerCategoryStore)
}

// MARK: - TrackerCategoryStore
final class TrackerCategoryStore: NSObject {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    private var cachedCategories: [TrackerCategory] = []
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Initialization
    override convenience init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
        updateCache()
    }
    
    // MARK: - Public Properties
    var allCategories: [TrackerCategory] {
        return cachedCategories
    }
    
    var numberOfItems: Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func category(at indexPath: IndexPath) -> TrackerCategory? {
        guard let coreData = fetchedResultsController.fetchedObjects?[indexPath.row] else {
            return nil
        }
        return convertToCategory(from: coreData)
    }
    
    // MARK: - Create
    func createCategory(title: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try saveContext()
    }
    
    // MARK: - Get
    func getOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        
        if let existing = try context.fetch(fetchRequest).first {
            return existing
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        try saveContext()
        return newCategory
    }
    
    func fetchCategory(by title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        return try context.fetch(fetchRequest).first
    }
    
    // MARK: - Delete
    func deleteCategory(by title: String) throws {
        guard let category = try fetchCategory(by: title) else {
            return
        }
        context.delete(category)
        try saveContext()
    }
    
    // MARK: - Private Methods
    private func convertToCategory(from coreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = coreData.title else {
            return nil
        }
        
        return TrackerCategory(
            title: title,
            trackers: []
        )
    }
    
    private func updateCache() {
        cachedCategories = (fetchedResultsController.fetchedObjects ?? [])
            .compactMap { convertToCategory(from: $0) }
    }
    
    private func saveContext() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateCache()
        delegate?.storeDidChange(self)
    }
}
