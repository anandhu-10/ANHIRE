import os
import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Instructions:
# 1. Download your service account key JSON file from Firebase Console (Project Settings -> Service Accounts).
# 2. Rename it to 'serviceAccountKey.json' and place it in the same directory as this script.
# 3. Run: pip install firebase-admin
# 4. Run: python seed_firestore.py

cred_path = "assets/serviceAccountKey.json"

if not os.path.exists(cred_path):
    print("-------------------------------------------------------------------------")
    print("ERROR: Firebase credentials file 'assets/serviceAccountKey.json' not found.")
    print("Please download it from Firebase Console and place it in the assets folder.")
    print("-------------------------------------------------------------------------")
    exit(1)

# Initialize Firebase Admin SDK
cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred)
db = firestore.client()

def seed_aptitude():
    print("Seeding Aptitude Questions...")
    categories = ["quantitative", "logical", "verbal"]
    count = 0
    for cat in categories:
        filepath = f"assets/aptitude/{cat}.json"
        if os.path.exists(filepath):
            with open(filepath, "r") as f:
                questions = json.load(f)
                for q in questions:
                    # Write to firestore collection
                    db.collection("aptitude_questions").document(q["id"]).set({
                        "id": q["id"],
                        "category": q["category"],
                        "topic": q["topic"],
                        "questionText": q["questionText"],
                        "options": q["options"],
                        "correctOptionIndex": q["correctOptionIndex"],
                        "difficulty": q["difficulty"],
                        "explanation": q["explanation"]
                    })
                    count += 1
    print(f"Successfully seeded {count} Aptitude Questions.")

def seed_interviews():
    print("Seeding Interview Questions...")
    topics = ["hr", "flutter", "python", "java", "dbms"]
    count = 0
    for topic in topics:
        filepath = f"assets/interview/{topic}.json"
        if os.path.exists(filepath):
            with open(filepath, "r") as f:
                questions = json.load(f)
                for q in questions:
                    db.collection("interviews").document(q["id"]).set({
                        "id": q["id"],
                        "type": q["type"],
                        "role": q["role"],
                        "questionText": q["questionText"],
                        "idealKeywords": q["idealKeywords"],
                        "suggestedAnswer": q["suggestedAnswer"]
                    })
                    count += 1
    print(f"Successfully seeded {count} Interview Questions.")

def seed_demo_accounts():
    print("Creating Demo accounts indicators...")
    # Seed mock students/admin in leaderboard for demonstration rankings
    demo_entries = [
        {"uid": "mock_student_uid", "name": "Anandhu S", "collegeName": "CET", "readinessScore": 84.0, "aptitudeScore": 80.0},
        {"uid": "uid2", "name": "Abhiram K", "collegeName": "CET", "readinessScore": 92.0, "aptitudeScore": 90.0},
        {"uid": "uid3", "name": "Sandra Philip", "collegeName": "TKM", "readinessScore": 78.0, "aptitudeScore": 75.0},
        {"uid": "uid4", "name": "Rithvik Raju", "collegeName": "CET", "readinessScore": 68.0, "aptitudeScore": 70.0},
        {"uid": "uid5", "name": "Fathima N", "collegeName": "GECB", "readinessScore": 86.0, "aptitudeScore": 82.0},
        {"uid": "uid6", "name": "Rahul Das", "collegeName": "TKM", "readinessScore": 45.0, "aptitudeScore": 50.0},
    ]
    
    for entry in demo_entries:
        db.collection("leaderboard").document(entry["uid"]).set({
            "uid": entry["uid"],
            "name": entry["name"],
            "collegeName": entry["collegeName"],
            "readinessScore": entry["readinessScore"],
            "aptitudeScore": entry["aptitudeScore"],
            "updatedAt": firestore.SERVER_TIMESTAMP
        })
    print("Successfully seeded demo leaderboard entries.")

if __name__ == "__main__":
    seed_aptitude()
    seed_interviews()
    seed_demo_accounts()
    print("Database seeding completed successfully!")
