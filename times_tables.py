"""Times-tables quiz: 10 random questions, score at the end."""
import random

def main():
    print("Times-tables quiz! 10 questions. Type your answer and press Enter.\n")
    score = 0
    for n in range(1, 11):
        a, b = random.randint(2, 12), random.randint(2, 12)
        answer = input(f"Q{n}: {a} x {b} = ")
        try:
            correct = int(answer) == a * b
        except ValueError:
            correct = False
        if correct:
            score += 1
            print("Correct!\n")
        else:
            print(f"Not quite, it's {a * b}.\n")
    print(f"You scored {score} out of 10.")
    if score == 10:
        print("Perfect score!")

if __name__ == "__main__":
    main()
