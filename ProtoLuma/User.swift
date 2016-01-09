import Foundation

class User: PFUser {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var facebookId: String
    
    class func isLoggedIn() -> Bool {
        return User.currentUser() != nil
    }
    
    func fullName() -> String{
        return "\(firstName) \(lastName)"
    }
}