class StaffModel {
    String? staffPassword; // Password for the staff
    String? staffEmail; // Email address of the staff
    String? staffName; // Name of the staff
    String? staffPhone; // Phone number of the staff
    String? userId; // ID of the user associated with this staff
    String? id; // Unique ID for the staff
    String? imageUrl; // Image URL of the staff (optional)

    // Constructor for creating a StaffModel object
    StaffModel({
        this.staffPassword,
        this.staffEmail,
        this.staffName,
        this.staffPhone,
        this.userId,
        this.id,
        this.imageUrl,
    });

    // Converts a StaffModel object to a Map<String, dynamic>
    Map<String, dynamic> toMap() {
        return {
            "staffPassword": staffPassword, // Staff password
            "staffEmail": staffEmail, // Staff email
            "staffName": staffName, // Staff name
            "staffPhone": staffPhone, // Staff phone number
            "userId": userId, // User ID associated with this staff
            "id": id, // Staff ID (unique identifier)
            "imageUrl": imageUrl, // Image URL for the staff (optional)
        };
    }

    // Factory constructor that creates a StaffModel from a Map
    factory StaffModel.fromMap(String? staffId, Map<String, dynamic> data) {
        return StaffModel(
            staffPassword: data["staffPassword"], // Staff password
            staffEmail: data["staffEmail"], // Staff email
            staffName: data["staffName"], // Staff name
            staffPhone: data["staffPhone"], // Staff phone number
            userId: data["userId"], // User ID associated with the staff
            id: staffId, // Staff ID (unique identifier)
            imageUrl: data["imageUrl"], // Image URL (optional)
        );
    }
}
