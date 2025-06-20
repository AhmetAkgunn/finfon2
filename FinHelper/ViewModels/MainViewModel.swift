import Foundation
import SwiftUI

// Ana uygulama verilerini yöneten ViewModel
class MainViewModel: ObservableObject {
    @Published var currentUser: User
    @Published var groups: [Group] = []
    @Published var selectedGroup: Group?
    @Published var expenses: [Expense] = []
    
    var totalExpenses: Double? {
        guard !expenses.isEmpty else { return nil }
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    init() {
        // Kullanıcı bilgisini UserDefaults'tan al
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
        } else {
            self.currentUser = User.emptyUser()
        }
        
        // Kullanıcının harcamalarını yükle
        loadExpenses()
        loadGroups()
        
        // Uygulama ilk açıldığında selectedGroup'u sıfırla
        selectedGroup = nil
    }
    
    // MARK: - Expense Operations
    
    private func loadExpenses() {
        // UserDefaults'tan kullanıcıya ait harcamaları yükle
        if let expensesData = UserDefaults.standard.data(forKey: "expenses_\(currentUser.id)"),
           let loadedExpenses = try? JSONDecoder().decode([Expense].self, from: expensesData) {
            self.expenses = loadedExpenses
        }
    }
    
    private func saveExpenses() {
        // Kullanıcıya ait harcamaları UserDefaults'a kaydet
        if let expensesData = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(expensesData, forKey: "expenses_\(currentUser.id)")
        }
    }
    
    func addExpense(title: String, amount: Double, category: ExpenseCategory) {
        let newExpense = Expense(
            title: title,
            amount: amount,
            date: Date(),
            category: category,
            userId: currentUser.id
        )
        expenses.append(newExpense)
        saveExpenses()
    }
    
    func updateExpense(id: UUID, title: String, amount: Double, category: ExpenseCategory) {
        if let index = expenses.firstIndex(where: { $0.id == id }) {
            var updatedExpense = expenses[index]
            updatedExpense.title = title
            updatedExpense.amount = amount
            updatedExpense.category = category
            expenses[index] = updatedExpense
            saveExpenses()
        }
    }
    
    func deleteExpense(at indexSet: IndexSet) {
        expenses.remove(atOffsets: indexSet)
        saveExpenses()
    }
    
    // MARK: - Group Operations
    
    private func loadGroups() {
        // UserDefaults'tan kullanıcıya ait grupları yükle
        if let groupsData = UserDefaults.standard.data(forKey: "groups_\(currentUser.id)"),
           let loadedGroups = try? JSONDecoder().decode([Group].self, from: groupsData) {
            self.groups = loadedGroups
        }
    }
    
    func saveGroups() {
        // Kullanıcıya ait grupları UserDefaults'a kaydet
        if let groupsData = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(groupsData, forKey: "groups_\(currentUser.id)")
        }
    }
    
    func createGroup(name: String, members: [String], icon: String) {
        let newGroup = Group(
            name: name,
            members: members,
            expenses: [],
            date: Date(),
            icon: icon
        )
        groups.append(newGroup)
        saveGroups()
    }
    
    func addExpense(to group: Group, title: String, amount: Double, paidBy: String, splitBetween: [String], category: ExpenseCategory) {
        let expense = Expense(
            title: title,
            amount: amount,
            date: Date(),
            category: category,
            paidBy: paidBy,
            splitBetween: splitBetween,
            userId: currentUser.id
        )
        
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].expenses.append(expense)
            saveGroups()
        }
    }
    
    func updateGroupExpense(groupId: UUID, expense: Expense) {
        if let groupIndex = groups.firstIndex(where: { $0.id == groupId }),
           let expenseIndex = groups[groupIndex].expenses.firstIndex(where: { $0.id == expense.id }) {
            groups[groupIndex].expenses[expenseIndex] = expense
            saveGroups()
        }
    }
    
    func deleteGroupExpense(groupId: UUID, expenseId: UUID) {
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].expenses.removeAll { $0.id == expenseId }
        }
    }
    
    func deleteGroups(at offsets: IndexSet) {
        groups.remove(atOffsets: offsets)
        saveGroups()
    }
    
    // Grup güncelleme fonksiyonu
    func updateGroup(_ updatedGroup: Group) {
        if let index = groups.firstIndex(where: { $0.id == updatedGroup.id }) {
            groups[index] = updatedGroup
        }
    }
    
    // MARK: - User Operations
    
    func clearUserData() {
        // Kullanıcı verilerini temizle
        UserDefaults.standard.removeObject(forKey: "expenses_\(currentUser.id)")
        UserDefaults.standard.removeObject(forKey: "groups_\(currentUser.id)")
        expenses = []
        groups = []
    }
} 