 	
    module MyModule::TodoList {
    use aptos_framework::signer;
    use std::vector;
    use std::string::{Self, String};

    /// Struct representing a single todo item
    struct TodoItem has store, copy, drop {
        id: u64,           // Unique identifier for the todo item
        description: String, // Description of the todo task
        completed: bool,   // Status of the todo item
    }

    /// Struct representing the user's todo list
    struct TodoList has store, key {
        items: vector<TodoItem>, // Vector of todo items
        next_id: u64,           // Counter for next todo item ID
    }

    /// Function to create a new todo list for the user
    public fun create_todo_list(owner: &signer) {
        let todo_list = TodoList {
            items: vector::empty<TodoItem>(),
            next_id: 1,
        };
        move_to(owner, todo_list);
    }

    /// Function to add a new todo item to the user's list
    public fun add_todo_item(
        owner: &signer, 
        description: String
    ) acquires TodoList {
        let owner_addr = signer::address_of(owner);
        let todo_list = borrow_global_mut<TodoList>(owner_addr);
        
        // Create new todo item
        let new_item = TodoItem {
            id: todo_list.next_id,
            description,
            completed: false,
        };
        
        // Add item to the list and increment counter
        vector::push_back(&mut todo_list.items, new_item);
        todo_list.next_id = todo_list.next_id + 1;
    }

    /// Function to mark a todo item as completed
    public fun complete_todo_item(
        owner: &signer, 
        todo_id: u64
    ) acquires TodoList {
        let owner_addr = signer::address_of(owner);
        let todo_list = borrow_global_mut<TodoList>(owner_addr);
        
        let len = vector::length(&todo_list.items);
        let i = 0;
        
        // Find and update the todo item
        while (i < len) {
            let item = vector::borrow_mut(&mut todo_list.items, i);
            if (item.id == todo_id) {
                item.completed = true;
                break
            };
            i = i + 1;
        };
    }
}
