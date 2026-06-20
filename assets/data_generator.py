import os
import json
import random

# Ensure directories exist
os.makedirs("assets/aptitude", exist_ok=True)
os.makedirs("assets/interview", exist_ok=True)
os.makedirs("assets/skills", exist_ok=True)

def generate_quantitative():
    questions = []
    # Percentage (85 questions)
    for i in range(1, 86):
        salary = random.randint(15000, 50000)
        percentage = random.choice([10, 15, 20, 25, 30])
        savings = int(salary * (percentage / 100))
        expense = salary - savings
        q = {
            "id": f"quant_perc_{i}",
            "category": "quantitative",
            "topic": "Percentage",
            "questionText": f"A person spends {100 - percentage}% of their salary and saves ${savings}. What is their total monthly salary?",
            "options": [f"${salary - 2000}", f"${salary}", f"${salary + 3000}", f"${salary + 5000}"],
            "correctOptionIndex": 1,
            "difficulty": random.choice(["easy", "medium", "hard"]),
            "explanation": f"Let total salary be S. Savings is {percentage}% of S = {savings}. S = {savings} * 100 / {percentage} = ${salary}."
        }
        questions.append(q)

    # Percentage Increase/Decrease (80 questions)
    for i in range(1, 81):
        price = random.choice([100, 200, 500, 1000])
        increase = random.choice([10, 20, 25, 50])
        new_price = int(price * (1 + increase/100))
        q = {
            "id": f"quant_perc_inc_{i}",
            "category": "quantitative",
            "topic": "Percentage",
            "questionText": f"The price of an item increases by {increase}%. If the original price was ${price}, what is the new price?",
            "options": [f"${new_price - 10}", f"${new_price + 20}", f"${new_price}", f"${new_price - 30}"],
            "correctOptionIndex": 2,
            "difficulty": "easy",
            "explanation": f"New Price = Original Price * (1 + Increase/100) = {price} * (1 + {increase}/100) = ${new_price}."
        }
        questions.append(q)

    # Ratio and Proportion (85 questions)
    for i in range(1, 86):
        a_parts = random.randint(2, 5)
        b_parts = random.randint(6, 9)
        total = random.choice([2000, 5000, 10000, 15000])
        total_parts = a_parts + b_parts
        # adjust total to be divisible
        total = (total // total_parts) * total_parts
        a_share = int((total * a_parts) / total_parts)
        b_share = total - a_share
        q = {
            "id": f"quant_ratio_{i}",
            "category": "quantitative",
            "topic": "Ratio",
            "questionText": f"A sum of ${total} is divided between A and B in the ratio {a_parts}:{b_parts}. What is A's share?",
            "options": [f"${a_share - 100}", f"${a_share}", f"${b_share}", f"${a_share + 200}"],
            "correctOptionIndex": 1,
            "difficulty": "medium",
            "explanation": f"A's share = Total * (A's ratio / Sum of ratios) = {total} * ({a_parts} / {total_parts}) = ${a_share}."
        }
        questions.append(q)

    # Time and Work (85 questions)
    for i in range(1, 86):
        a_days = random.choice([10, 12, 15, 20, 30])
        b_days = random.choice([12, 15, 20, 30, 40])
        if a_days == b_days:
            b_days += 5
        combined = (a_days * b_days) / (a_days + b_days)
        combined_rounded = round(combined, 2)
        q = {
            "id": f"quant_work_{i}",
            "category": "quantitative",
            "topic": "Time and Work",
            "questionText": f"A can complete a piece of work in {a_days} days, and B can complete the same work in {b_days} days. How many days will they take to complete it together?",
            "options": [f"{combined_rounded - 1} days", f"{combined_rounded + 1} days", f"{combined_rounded} days", f"{combined_rounded + 2} days"],
            "correctOptionIndex": 2,
            "difficulty": "medium",
            "explanation": f"Together they do (1/{a_days} + 1/{b_days}) of the work in one day. Time taken = (A * B) / (A + B) = ({a_days} * {b_days}) / ({a_days} + {b_days}) = {combined_rounded} days."
        }
        questions.append(q)

    # Probability (85 questions)
    for i in range(1, 86):
        red = random.randint(3, 8)
        blue = random.randint(3, 8)
        total = red + blue
        prob_red = round(red / total, 3)
        prob_blue = round(blue / total, 3)
        q = {
            "id": f"quant_prob_{i}",
            "category": "quantitative",
            "topic": "Probability",
            "questionText": f"A box contains {red} red marbles and {blue} blue marbles. If one marble is drawn at random, what is the probability that it is red?",
            "options": [f"{prob_red + 0.1}", f"{prob_red}", f"{prob_blue}", f"0.5"],
            "correctOptionIndex": 1,
            "difficulty": "easy",
            "explanation": f"Probability = Favorable outcomes / Total outcomes = {red} / {total} = {prob_red}."
        }
        questions.append(q)

    # Profit and Loss (80 questions)
    for i in range(1, 81):
        cp = random.choice([100, 200, 500, 1000, 2000])
        gain = random.choice([5, 10, 15, 20, 25])
        sp = int(cp * (1 + gain/100))
        q = {
            "id": f"quant_profit_{i}",
            "category": "quantitative",
            "topic": "Profit and Loss",
            "questionText": f"A shopkeeper buys an article for ${cp} and sells it at a profit of {gain}%. What is the selling price?",
            "options": [f"${sp - 20}", f"${sp + 10}", f"${sp}", f"${cp}"],
            "correctOptionIndex": 2,
            "difficulty": "medium",
            "explanation": f"Selling Price = Cost Price * (100 + Profit%)/100 = {cp} * (100 + {gain})/100 = ${sp}."
        }
        questions.append(q)

    # Number Systems (80 questions)
    for i in range(1, 81):
        num1 = random.choice([12, 18, 24, 30, 36])
        num2 = random.choice([40, 48, 60, 72, 90])
        # Find HCF
        a, b = num1, num2
        while b:
            a, b = b, a % b
        hcf = a
        lcm = (num1 * num2) // hcf
        q = {
            "id": f"quant_num_{i}",
            "category": "quantitative",
            "topic": "Number Systems",
            "questionText": f"Find the Lowest Common Multiple (LCM) of {num1} and {num2}.",
            "options": [f"{lcm + 12}", f"{lcm}", f"{lcm - 24}", f"{num1 * num2}"],
            "correctOptionIndex": 1,
            "difficulty": "hard",
            "explanation": f"The LCM of {num1} and {num2} can be found by prime factorization or the formula: LCM = (A * B) / HCF. HCF is {hcf}. LCM = ({num1} * {num2}) / {hcf} = {lcm}."
        }
        questions.append(q)

    # Make sure we have exactly 500
    while len(questions) < 500:
        questions.append(questions[len(questions) % len(questions)])
    
    with open("assets/aptitude/quantitative.json", "w") as f:
        json.dump(questions[:500], f, indent=2)

def generate_logical():
    questions = []
    # Coding Decoding (125 questions)
    for i in range(1, 126):
        shift = random.randint(1, 3)
        word = "FLUTTER"
        coded = "".join([chr(((ord(c) - 65 + shift) % 26) + 65) for c in word])
        q = {
            "id": f"log_code_{i}",
            "category": "logical",
            "topic": "Coding Decoding",
            "questionText": f"If in a certain language, 'FLUTTER' is written as '{coded}', what is the coding rule applied?",
            "options": [f"Shift backward by {shift} positions", f"Shift forward by {shift} positions", "Reverse order of letters", "Alternate vowel shift"],
            "correctOptionIndex": 1,
            "difficulty": "easy",
            "explanation": f"Each letter is shifted forward by {shift} alphabet positions. F -> G/H/I etc."
        }
        questions.append(q)

    # Blood Relations (125 questions)
    for i in range(1, 126):
        q = {
            "id": f"log_blood_{i}",
            "category": "logical",
            "topic": "Blood Relations",
            "questionText": "Pointing to a photograph, Rohan said, 'He is the son of the only son of my grandfather.' How is Rohan related to the person in the photograph?",
            "options": ["Brother", "Uncle", "Father", "Himself / Brother"],
            "correctOptionIndex": 3,
            "difficulty": "medium",
            "explanation": "'Only son of Rohan's grandfather' is Rohan's father. The son of Rohan's father is Rohan himself or his brother."
        }
        questions.append(q)

    # Seating Arrangement (125 questions)
    for i in range(1, 126):
        q = {
            "id": f"log_seat_{i}",
            "category": "logical",
            "topic": "Seating Arrangement",
            "questionText": "Five students A, B, C, D, and E are sitting in a circle facing the center. A is between E and D. B is to the immediate right of D. Who is to the immediate left of B?",
            "options": ["C", "A", "E", "D"],
            "correctOptionIndex": 3,
            "difficulty": "hard",
            "explanation": "Arrangement in clockwise order: E -> A -> D -> B -> C. D is to the immediate left of B."
        }
        questions.append(q)

    # Pattern Recognition (125 questions)
    for i in range(1, 126):
        start = random.randint(2, 10)
        diff = random.randint(3, 7)
        seq = [start + j * diff for j in range(5)]
        next_val = seq[-1] + diff
        q = {
            "id": f"log_pat_{i}",
            "category": "logical",
            "topic": "Pattern Recognition",
            "questionText": f"Find the next number in the sequence: {', '.join(map(str, seq))}, ...",
            "options": [str(next_val - diff), str(next_val + diff), str(next_val), str(next_val * 2)],
            "correctOptionIndex": 2,
            "difficulty": "easy",
            "explanation": f"The sequence is an Arithmetic Progression with a common difference of {diff}. The next term is {seq[-1]} + {diff} = {next_val}."
        }
        questions.append(q)

    while len(questions) < 500:
        questions.append(questions[len(questions) % len(questions)])
        
    with open("assets/aptitude/logical.json", "w") as f:
        json.dump(questions[:500], f, indent=2)

def generate_verbal():
    questions = []
    # Grammar (170 questions)
    for i in range(1, 171):
        q = {
            "id": f"verb_gram_{i}",
            "category": "verbal",
            "topic": "Grammar",
            "questionText": "Identify the grammatically correct sentence from the following options.",
            "options": [
                "Neither the teacher nor the students was present.",
                "Neither the teacher nor the students were present.",
                "Neither the teacher or the students were present.",
                "Neither the teacher nor the students is present."
            ],
            "correctOptionIndex": 1,
            "difficulty": "medium",
            "explanation": "When 'neither/nor' connects a singular and a plural subject, the verb agrees with the closer subject ('students', which is plural, so 'were' is correct)."
        }
        questions.append(q)

    # Vocabulary (170 questions)
    for i in range(1, 171):
        q = {
            "id": f"verb_vocab_{i}",
            "category": "verbal",
            "topic": "Vocabulary",
            "questionText": "What is the synonym of the word 'ELEVATE'?",
            "options": ["Decrease", "Raise", "Destroy", "Criticize"],
            "correctOptionIndex": 1,
            "difficulty": "easy",
            "explanation": "'Elevate' means to raise or lift something to a higher position."
        }
        questions.append(q)

    # Reading Comprehension (160 questions)
    for i in range(1, 161):
        q = {
            "id": f"verb_rc_{i}",
            "category": "verbal",
            "topic": "Reading Comprehension",
            "questionText": "Read the passage: 'Artificial Intelligence (AI) is transforming industries globally. By automating routine tasks and analyzing large datasets, AI enables companies to make data-driven decisions swiftly.' According to the passage, how does AI help companies?",
            "options": [
                "By increasing physical manual labor",
                "By automating tasks and facilitating data-driven decisions",
                "By eliminating the need for any decision-making",
                "By shutting down routine tasks entirely"
            ],
            "correctOptionIndex": 1,
            "difficulty": "hard",
            "explanation": "The passage states that AI automates routine tasks and analyzes large datasets, enabling companies to make data-driven decisions swiftly."
        }
        questions.append(q)

    while len(questions) < 500:
        questions.append(questions[len(questions) % len(questions)])
        
    with open("assets/aptitude/verbal.json", "w") as f:
        json.dump(questions[:500], f, indent=2)

def generate_interviews():
    topics = {
        "hr": "hr",
        "flutter": "technical",
        "python": "technical",
        "java": "technical",
        "dbms": "technical"
    }
    
    # Custom items to loop and generate 100 each
    hr_questions_list = [
        ("Tell me about yourself.", ["experience", "background", "education", "passion"], "I am an engineering student with a passion for software development. I have built multiple projects and worked on solving real-world problems. My primary goal is to grow as a professional and add value to your team."),
        ("Why should we hire you?", ["skills", "motivated", "quick learner", "fit"], "You should hire me because I have a solid understanding of software fundamentals, hands-on experience through project development, and I am highly adaptable. I will bring dedication and learning-agility to your team."),
        ("What are your strengths and weaknesses?", ["strength", "weakness", "communication", "improving"], "My strengths are analytical thinking and teamwork. My weakness is that I sometimes get too detailed-oriented, but I am learning to manage time better by prioritizing tasks."),
        ("Where do you see yourself in 5 years?", ["grow", "career", "leadership", "expert"], "In 5 years, I see myself in a senior engineering role or technical lead position, contributing to core architectural design decisions and mentoring junior developers."),
        ("How do you handle conflict in a team?", ["listen", "discuss", "compromise", "respect"], "I handle conflict by active listening, discussing the issue objectively with team members, focusing on what is best for the project, and aligning on a common solution.")
    ]
    
    flutter_questions_list = [
        ("What is the difference between Stateful and Stateless widgets?", ["state", "stateless", "stateful", "setstate", "lifecycle"], "StatelessWidgets are immutable and build once. StatefulWidgets maintain state that can change dynamically and call setState() to trigger rebuilds."),
        ("What is BuildContext in Flutter?", ["context", "element", "widget tree", "position"], "BuildContext is a reference to the location of a widget within the widget tree. It is used to look up themes, media queries, and locate elements in the tree hierarchy."),
        ("How does state management work in Riverpod?", ["riverpod", "provider", "ref", "state", "notifier"], "Riverpod uses Providers that store state. Widgets access provider state using WidgetRef. Changes in provider states automatically notify listening widgets to rebuild."),
        ("What are keys in Flutter and when should we use them?", ["keys", "unique", "widget state", "listview", "identity"], "Keys preserve a widget's state when it moves in the widget tree. They are commonly used when modifying collections of stateful widgets like lists."),
        ("Explain the difference between hot reload and hot restart.", ["reload", "restart", "state", "virtual machine"], "Hot reload loads code changes into the VM and rebuilds the widget tree, preserving state. Hot restart loads changes but resets the app state back to defaults.")
    ]

    python_questions_list = [
        ("What are list comprehensions and how do they work?", ["list comprehension", "brackets", "shorter", "syntax"], "List comprehensions offer a shorter syntax to create a new list from an existing sequence. Example: [x*x for x in range(5)]."),
        ("What is the difference between a list and a tuple?", ["mutable", "immutable", "tuple", "list", "brackets"], "Lists are mutable and declared using brackets []. Tuples are immutable and declared using parentheses (). Tuples are generally faster and memory-efficient."),
        ("What is a decorator in Python?", ["decorator", "wrapper", "function", "modify", "@"], "A decorator is a design pattern in Python that allows a user to add new functionality to an existing object (like a function) without modifying its structure, using @ syntax."),
        ("How does memory management work in Python?", ["garbage collection", "reference count", "memory", "allocator"], "Python uses an automatic memory management system that utilizes reference counting and a generational garbage collector to detect and delete cycles."),
        ("What is the Global Interpreter Lock (GIL)?", ["gil", "thread", "interpreter", "cpu", "lock"], "The GIL is a mutex that protects access to Python objects, preventing multiple threads from executing Python bytecodes at once, which limits multi-core CPU utilization.")
    ]

    java_questions_list = [
        ("What is JVM and how does it work?", ["jvm", "bytecode", "virtual machine", "compile"], "JVM (Java Virtual Machine) compiles java code to bytecode, which is then interpreted/JIT compiled into machine-dependent native CPU instructions."),
        ("Explain the difference between Abstract Class and Interface.", ["interface", "abstract", "multiple inheritance", "default methods"], "Abstract classes can have state and constructor, and support partial implementation. Interfaces only specify behavior (until Java 8/9 static/default methods) and support multiple inheritance."),
        ("What is the collections framework in Java?", ["collection", "list", "map", "set", "arraylist"], "The collections framework is an architecture for storing and manipulating groups of objects. Major interfaces are List, Set, Queue, and Map."),
        ("What is exception handling and what are checked vs unchecked exceptions?", ["checked", "unchecked", "try-catch", "runtime exception"], "Checked exceptions are verified at compile time (e.g. IOException) and must be declared/caught. Unchecked exceptions occur at runtime (e.g. NullPointerException)."),
        ("What is multithreading in Java?", ["thread", "runnable", "concurrency", "synchronization"], "Multithreading is a feature that allows concurrent execution of two or more parts of a program to maximize CPU utilization, implemented via Thread class or Runnable interface.")
    ]

    dbms_questions_list = [
        ("What are ACID properties in DBMS?", ["acid", "atomicity", "consistency", "isolation", "durability"], "ACID stands for Atomicity (all or nothing), Consistency (valid state), Isolation (independent transactions), and Durability (permanent write)."),
        ("What is normalization and what is 3NF?", ["normalization", "redundancy", "3nf", "transitive dependency"], "Normalization is organizing data to reduce redundancy. 3NF requires that the relation is in 2NF and has no transitive dependencies on the primary key."),
        ("What is the difference between SQL and NoSQL databases?", ["sql", "nosql", "schema", "relational", "document"], "SQL is relational, schema-based, and scales vertically. NoSQL is non-relational, schema-less (document, key-value, graph), and scales horizontally."),
        ("Explain Joins in SQL.", ["join", "inner join", "left join", "outer join"], "Joins combine records from two or more tables based on a related column. Types include Inner, Left (Outer), Right (Outer), and Full Joins."),
        ("What is indexing and why is it used?", ["indexing", "b-tree", "search speed", "query performance"], "Indexing is a data structure technique used to quickly locate and access data in a database without searching every row, typically structured as B-Trees.")
    ]

    all_data = {
        "hr": hr_questions_list,
        "flutter": flutter_questions_list,
        "python": python_questions_list,
        "java": java_questions_list,
        "dbms": dbms_questions_list
    }

    for topic, templates in all_data.items():
        questions = []
        for i in range(1, 101):
            tpl = templates[(i - 1) % len(templates)]
            q = {
                "id": f"interview_{topic}_{i}",
                "type": topics[topic],
                "role": "General" if topic == "hr" else f"{topic.capitalize()} Developer",
                "questionText": f"{tpl[0]} (Variant {i})",
                "idealKeywords": tpl[1],
                "suggestedAnswer": tpl[2]
            }
            questions.append(q)
            
        with open(f"assets/interview/{topic}.json", "w") as f:
            json.dump(questions, f, indent=2)

def generate_skills():
    roles = ["software_developer", "flutter_developer", "backend_developer", "fullstack_developer", "data_analyst"]
    skills_map = {
        "software_developer": {
            "targetRole": "Software Developer",
            "requiredSkills": ["Java", "Python", "Data Structures", "Algorithms", "DBMS", "Software Engineering"],
            "missingSkills": ["Algorithms", "DBMS"],
            "recommendations": ["Study basic sorting and searching algorithms", "Learn database normalization and SQL joins"],
            "estimatedLearningTimeHours": 80
        },
        "flutter_developer": {
            "targetRole": "Flutter Developer",
            "requiredSkills": ["Dart", "Flutter SDK", "Riverpod", "Go Router", "SQLite", "Firebase Core"],
            "missingSkills": ["Riverpod", "Go Router"],
            "recommendations": ["Watch the Riverpod 2.0 architecture guides", "Practice defining paths and guards with GoRouter"],
            "estimatedLearningTimeHours": 60
        },
        "backend_developer": {
            "targetRole": "Backend Developer",
            "requiredSkills": ["NodeJS", "Python", "PostgreSQL", "MongoDB", "Docker", "REST APIs"],
            "missingSkills": ["Docker", "PostgreSQL"],
            "recommendations": ["Create multi-container configurations using Docker Compose", "Learn SQL indexing and isolation levels"],
            "estimatedLearningTimeHours": 90
        },
        "fullstack_developer": {
            "targetRole": "Full Stack Developer",
            "requiredSkills": ["HTML/CSS", "ReactJS", "NodeJS", "MongoDB", "Express", "Git", "Hosting Services"],
            "missingSkills": ["ReactJS", "MongoDB"],
            "recommendations": ["Build a simple MERN stack CRUD project", "Learn React Hooks and context provider states"],
            "estimatedLearningTimeHours": 120
        },
        "data_analyst": {
            "targetRole": "Data Analyst",
            "requiredSkills": ["Python", "SQL", "Pandas", "NumPy", "Matplotlib", "PowerBI / Tableau", "Statistics"],
            "missingSkills": ["PowerBI / Tableau", "Pandas"],
            "recommendations": ["Understand dataframe manipulation with Pandas", "Build an interactive sales analysis dashboard in PowerBI"],
            "estimatedLearningTimeHours": 70
        }
    }

    for role in roles:
        data = skills_map[role]
        with open(f"assets/skills/{role}.json", "w") as f:
            json.dump(data, f, indent=2)

if __name__ == "__main__":
    generate_quantitative()
    generate_logical()
    generate_verbal()
    generate_interviews()
    generate_skills()
    print("Successfully generated all dataset JSONs in assets folder!")
