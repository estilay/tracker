import UIKit

// MARK: - CategoryViewModel
final class CategoryViewModel {
    
    // MARK: - Bindings
    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - Properties
    private let categoryStore: TrackerCategoryStore
    
    private(set) var categories: [String] = []
    private(set) var selectedCategory: String?
    
    // MARK: - Init
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore(),
         preselectedCategory: String? = nil) {
        self.categoryStore = categoryStore
        self.selectedCategory = preselectedCategory
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        categories = categoryStore.allCategories.map { $0.title }
        onCategoriesChanged?()
    }
    
    func numberOfRows() -> Int {
        return categories.count
    }
    
    func category(at indexPath: IndexPath) -> String {
        return categories[indexPath.row]
    }
    
    func isSelected(at indexPath: IndexPath) -> Bool {
        return categories[indexPath.row] == selectedCategory
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        selectedCategory = category
        onCategorySelected?(category)
    }
    
    func saveCategory(_ title: String) {
        do {
            try categoryStore.createCategory(title: title)
            loadCategories()
        } catch {
            print("[CategoryViewModel]: Failed to save category: \(error)")
        }
    }
}
