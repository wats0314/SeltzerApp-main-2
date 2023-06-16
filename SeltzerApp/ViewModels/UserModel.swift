//
//  UserModel.swift
//  SeltzerApp
//
//  Created by Mitch Watson on 6/9/23.
//

//
//  UserModel.swift
//  SeltzerApp
//
//  Created by Mitch Watson on 6/9/23.
//

import Foundation
import Firebase
import FirebaseFirestore

class UserModel: ObservableObject {
    @Published var currentUser: SeltzerAppUser?
    @Published var seltzers: [Seltzer] = []

    init() {
        // Check if the user is already signed in
        if let currentUser = Auth.auth().currentUser {
            fetchData(for: currentUser)
        }
    }

    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                print("Registration error: \(error.localizedDescription)")
                return
            }

            if let user = result?.user {
                // Create a new user document
                let newUser = SeltzerAppUser(id: user.uid, name: email, seltzers: [])
                self.currentUser = newUser

                let db = Firestore.firestore()

                // Convert the newUser object to a dictionary
                let userDict: [String: Any] = [
                    "id": newUser.id,
                    "name": newUser.name
                ]

                // Save the new user document to the "users" collection
                db.collection("users").document(user.uid).setData(userDict) { error in
                    if let error = error {
                        print("Error saving user document: \(error.localizedDescription)")
                    } else {
                        // Fetch seltzers from the "seltzers" collection
                        self.fetchSeltzers()
                    }
                }
            }
        }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            }

            if let user = result?.user {
                self.clearSeltzers()
                // Fetch user document (which will also fetch the seltzers)
                self.fetchUserData(for: user) // Pass the 'user' parameter here
            }
        }
    }


    private func fetchData(for user: User) {
        let db = Firestore.firestore()

        // Fetch the user document from the "users" collection
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("User document fetch error: \(error.localizedDescription)")
                return
            }

            if let document = snapshot, document.exists {
                // Parse the user document data
                if let data = document.data() as? [String: Any],
                   let name = data["name"] as? String {
                    // Create the user instance
                    let user = SeltzerAppUser(id: user.uid, name: name, seltzers: [])
                    self.currentUser = user

                    // Fetch seltzers from the "seltzers" collection
                    self.fetchSeltzers() // Move the fetchSeltzers() call here
                } else {
                    print("Invalid user document data")
                }
            }
        }
    }


    private func fetchSeltzers() {
        let db = Firestore.firestore()

        // Fetch all seltzer documents from the "seltzers" collection
        db.collection("seltzers").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Seltzer documents fetch error: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No seltzer documents found")
                return
            }

            // Clear the seltzers array before updating it with the fetched data
            self.seltzers = []

            // Parse the seltzer documents and update the seltzers array
            let seltzers = documents.compactMap { document -> Seltzer? in
                let data = document.data()

                // Check if data exists and is of type [String: Any]
                guard let data = data as? [String: Any],
                      let brand = data["brand"] as? String,
                      let flavor = data["flavor"] as? String,
                      let image = data["image"] as? String,
                      let scored = data["scored"] as? Bool,
                      let userScore = data["userScore"] as? Double,
                      let globalScore = data["globalScore"] as? Double else {
                    print("Invalid seltzer data in document \(document.documentID)")
                    return nil
                }

                return Seltzer(id: document.documentID, brand: brand, flavor: flavor, image: image, userScore: userScore, globalScore: globalScore, scored: scored)

            }

            // Update the seltzers array
            DispatchQueue.main.async {
                self.seltzers = seltzers
                self.saveSeltzers()
            }
        }
    }


    private func saveSeltzers() {
        guard let currentUser = currentUser else { return }

        let db = Firestore.firestore()

        // Get the reference to the user's seltzers subcollection
        let userSeltzersCollection = db.collection("users").document(currentUser.id).collection("seltzers")

        // Delete all existing seltzer documents in the user's seltzers subcollection
        userSeltzersCollection.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error deleting seltzer documents: \(error.localizedDescription)")
                return
            }

            // Delete each seltzer document
            snapshot?.documents.forEach { document in
                userSeltzersCollection.document(document.documentID).delete { error in
                    if let error = error {
                        print("Error deleting seltzer document \(document.documentID): \(error.localizedDescription)")
                    }
                }
            }

            // Save the updated seltzer data to the user's seltzers subcollection
            var updatedSeltzers: [Seltzer] = []

            for seltzer in self.seltzers {
                let seltzerDict: [String: Any] = [
                    "brand": seltzer.brand,
                    "flavor": seltzer.flavor,
                    "image": seltzer.image,
                    "userScore": seltzer.userScore,
                    "scored": seltzer.scored,
                    "globalScore": seltzer.globalScore
                ]

                // Add a new document for each seltzer in the user's seltzers subcollection
                userSeltzersCollection.addDocument(data: seltzerDict) { error in
                    if let error = error {
                        print("Error saving seltzer document: \(error.localizedDescription)")
                    }
                }

                // Append the seltzer to the updatedSeltzers array
                updatedSeltzers.append(seltzer)
            }

            // Assign the updated seltzers back to the currentUser property
            self.currentUser?.seltzers = updatedSeltzers
        }
    }

    
    func updateSeltzerData() {
        guard let currentUser = currentUser else { return }

        let db = Firestore.firestore()

        // Get the reference to the user's seltzers subcollection
        let userSeltzersCollection = db.collection("users").document(currentUser.id).collection("seltzers")

        // Delete all existing seltzer documents in the user's seltzers subcollection
        userSeltzersCollection.getDocuments { snapshot, error in
            if let error = error {
                print("Error deleting seltzer documents: \(error.localizedDescription)")
                return
            }

            // Delete each seltzer document
            snapshot?.documents.forEach { document in
                userSeltzersCollection.document(document.documentID).delete { error in
                    if let error = error {
                        print("Error deleting seltzer document \(document.documentID): \(error.localizedDescription)")
                    }
                }
            }

            // Save the updated seltzer data to the user's seltzers subcollection
            var updatedSeltzers: [Seltzer] = []

            for seltzer in currentUser.seltzers {
                let seltzerDict: [String: Any] = [
                    "brand": seltzer.brand,
                    "flavor": seltzer.flavor,
                    "image": seltzer.image,
                    "userScore": seltzer.userScore,
                    "scored": seltzer.scored,
                    "globalScore": seltzer.globalScore
                ]

                // Add a new document for each seltzer in the user's seltzers subcollection
                userSeltzersCollection.addDocument(data: seltzerDict) { error in
                    if let error = error {
                        print("Error saving seltzer document: \(error.localizedDescription)")
                    }
                }

                // Append the seltzer to the updatedSeltzers array
                updatedSeltzers.append(seltzer)
            }

            // Assign the updated seltzers back to the currentUser property
            self.currentUser?.seltzers = updatedSeltzers
            self.seltzers = updatedSeltzers // Update the seltzers array
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            seltzers = [] // Clear the seltzers array when signing out
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
    private func fetchUserData(for user: User) {
        let dispatchGroup = DispatchGroup()
        var userData: [String: Any]?
        var seltzerData: [Seltzer] = []

        let db = Firestore.firestore()

        // Fetch the user document from the "users" collection and the seltzers subcollection within it
        dispatchGroup.enter()
        db.collection("users").document(user.uid).getDocument { [weak self] userSnapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("User document fetch error: \(error.localizedDescription)")
            }

            if let userDocument = userSnapshot, userDocument.exists {
                // Parse the user document data
                userData = userDocument.data() as? [String: Any]

                // Fetch the seltzers subcollection within the user's document
                dispatchGroup.enter()
                db.collection("users").document(user.uid).collection("seltzers").getDocuments { [weak self] seltzerSnapshot, error in
                    guard let self = self else { return }

                    if let error = error {
                        print("Seltzer documents fetch error: \(error.localizedDescription)")
                    }

                    guard let seltzerDocuments = seltzerSnapshot?.documents else {
                        print("No seltzer documents found")
                        dispatchGroup.leave()
                        return
                    }

                    // Parse the seltzer documents
                    seltzerData = seltzerDocuments.compactMap { document -> Seltzer? in
                        let data = document.data()

                        // Check if data exists and is of type [String: Any]
                        guard let data = data as? [String: Any],
                              let brand = data["brand"] as? String,
                              let flavor = data["flavor"] as? String,
                              let image = data["image"] as? String,
                              let scored = data["scored"] as? Bool,
                              let userScore = data["userScore"] as? Double,
                              let globalScore = data["globalScore"] as? Double else {
                            print("Invalid seltzer data in document \(document.documentID)")
                            return nil
                        }

                        return Seltzer(id: document.documentID, brand: brand, flavor: flavor, image: image, userScore: userScore, globalScore: globalScore, scored: scored)

                    }

                    dispatchGroup.leave()
                }
            }

            dispatchGroup.leave()
        }

        // Notify when both fetch operations are completed
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            if let userData = userData, let name = userData["name"] as? String {
                // Create the user instance
                let user = SeltzerAppUser(id: user.uid, name: name, seltzers: seltzerData)
                self.currentUser = user
                self.seltzers = seltzerData
                self.saveSeltzers()
            } else {
                print("Invalid user document data")
            }
        }
    }

    private func clearSeltzers() {
        self.seltzers = []
    }


}
