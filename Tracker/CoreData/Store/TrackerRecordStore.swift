import CoreData
import UIKit

// MARK: - Delegate Protocol
protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidChange(_ store: TrackerRecordStore)
}

// MARK: - Errors
enum TrackerRecordStoreError: Error {
    case recordNotFound
    case saveFailed
    case fetchFailed
}

// MARK: - TrackerRecordStore
final class TrackerRecordStore: NSObject {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    private var cachedRecords: [TrackerRecord] = []
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Initialization
    override convenience init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: false)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
            updateCache()
        } catch {
            print("Failed to perform fetch: \(error)")
        }
    }
    
    // MARK: - Public Properties
    var allRecords: [TrackerRecord] {
        return cachedRecords
    }
    
    var numberOfItems: Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func record(at indexPath: IndexPath) -> TrackerRecord? {
        guard let coreData = fetchedResultsController?.fetchedObjects?[indexPath.row] else {
            return nil
        }
        return convertToRecord(from: coreData)
    }
    
    // MARK: - Create Record
    func addRecord(trackerId: UUID, date: Date) throws {
        if try isRecordExists(trackerId: trackerId, date: date) {
            return
        }
        
        let record = TrackerRecordCoreData(context: context)
        record.id = trackerId
        record.date = date
        
        try saveContext()
    }
    
    // MARK: - Delete Record
    func removeRecord(trackerId: UUID, date: Date) throws {
        let allRecords = try fetchAllCoreDataRecords()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        guard let record = allRecords.first(where: { coreData in
            guard let recordDate = coreData.date else { return false }
            return coreData.id == trackerId && calendar.isDate(recordDate, inSameDayAs: startOfDay)
        }) else {
            return
        }
        
        context.delete(record)
        try saveContext()
    }
    
    // MARK: - Read Records
    func isRecordExists(trackerId: UUID, date: Date) throws -> Bool {
        let allRecords = try fetchAllCoreDataRecords()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        return allRecords.contains { coreData in
            guard let recordDate = coreData.date else { return false }
            return coreData.id == trackerId && calendar.isDate(recordDate, inSameDayAs: startOfDay)
        }
    }
    
    func countRecords(for trackerId: UUID) throws -> Int {
        let allRecords = try fetchAllCoreDataRecords()
        return allRecords.filter { $0.id == trackerId }.count
    }
    
    func fetchRecordDates(for trackerId: UUID) throws -> [Date] {
        let allRecords = try fetchAllCoreDataRecords()
        return allRecords
            .filter { $0.id == trackerId }
            .compactMap { $0.date }
    }
    
    // MARK: - Private Methods
    private func fetchAllCoreDataRecords() throws -> [TrackerRecordCoreData] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        return try context.fetch(fetchRequest)
    }
    
    private func convertToRecord(from coreData: TrackerRecordCoreData) -> TrackerRecord? {
        guard let id = coreData.id,
              let date = coreData.date else {
            return nil
        }
        
        return TrackerRecord(
            id: id,
            date: date
        )
    }
    
    private func updateCache() {
        cachedRecords = (fetchedResultsController?.fetchedObjects ?? [])
            .compactMap { convertToRecord(from: $0) }
    }
    
    private func saveContext() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateCache()
        delegate?.storeDidChange(self)
    }
}
