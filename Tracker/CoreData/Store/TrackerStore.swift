import CoreData
import UIKit

// MARK: - Delegate Protocol
protocol TrackerStoreDelegate: AnyObject {
    func storeDidChange(_ store: TrackerStore)
}

// MARK: - TrackerStore
final class TrackerStore: NSObject {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    private var cachedTrackers: [Tracker] = []
    
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Initialization
    override convenience init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.title, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
        updateCache()
    }
    
    // MARK: - Public Properties
    var allTrackers: [Tracker] {
        return cachedTrackers
    }
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItems(in section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        guard let coreData = fetchedResultsController.sections?[indexPath.section].objects?[indexPath.row] as? TrackerCoreData else {
            return nil
        }
        return convertToTracker(from: coreData)
    }
    
    func categoryTitle(at section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
    
    // MARK: - Create
    func createTracker(
        id: UUID,
        name: String,
        icon: String,
        color: UIColor,
        schedule: [Schedule],
        categoryTitle: String
    ) throws {
        let category = try getOrCreateCategory(with: categoryTitle)
        
        let tracker = TrackerCoreData(context: context)
        tracker.id = id
        tracker.name = name
        tracker.icon = icon
        tracker.color = color.toHex()
        tracker.schedule = schedule.map { $0.rawValue }.joined(separator: ",")
        tracker.category = category
        
        try saveContext()
    }
    
    // MARK: - Delete
    func deleteTracker(by id: UUID) throws {
        let allTrackers = try fetchAllCoreDataTrackers()
        guard let tracker = allTrackers.first(where: { $0.id == id }) else {
            throw NSError(domain: "TrackerStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
        }
        context.delete(tracker)
        try saveContext()
    }
    
    // MARK: - Update
    func updateTracker(
        id: UUID,
        name: String? = nil,
        icon: String? = nil,
        color: UIColor? = nil,
        schedule: [Schedule]? = nil,
        categoryTitle: String? = nil
    ) throws {
        let allTrackers = try fetchAllCoreDataTrackers()
        guard let tracker = allTrackers.first(where: { $0.id == id }) else {
            throw NSError(domain: "TrackerStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
        }
        
        if let name = name { tracker.name = name }
        if let icon = icon { tracker.icon = icon }
        if let color = color { tracker.color = color.toHex() }
        if let schedule = schedule {
            tracker.schedule = schedule.map { $0.rawValue }.joined(separator: ",")
        }
        if let categoryTitle = categoryTitle {
            let category = try getOrCreateCategory(with: categoryTitle)
            tracker.category = category
        }
        try saveContext()
    }
    
    // MARK: - Private Methods
    private func getOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        
        if let existing = try context.fetch(fetchRequest).first {
            return existing
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        return newCategory
    }
    
    private func fetchAllCoreDataTrackers() throws -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        return try context.fetch(fetchRequest)
    }
    
    private func convertToTracker(from coreData: TrackerCoreData) -> Tracker? {
        guard let id = coreData.id,
              let name = coreData.name,
              let icon = coreData.icon,
              let colorHex = coreData.color,
              let scheduleString = coreData.schedule else {
            return nil
        }
        
        let schedule = scheduleString
            .split(separator: ",")
            .compactMap { Schedule(rawValue: String($0)) }
        
        return Tracker(
            id: id,
            name: name,
            icon: icon,
            color: UIColor(hex: colorHex) ?? .black,
            schedule: schedule
        )
    }
    
    private func updateCache() {
        cachedTrackers = (fetchedResultsController.fetchedObjects ?? [])
            .compactMap { convertToTracker(from: $0) }
    }
    
    private func saveContext() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateCache()
        delegate?.storeDidChange(self)
    }
}
