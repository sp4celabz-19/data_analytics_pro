# TASK 1

# a = 5
# b = 0
# c = ""
# d = "Hello"
# e = True
# f = False

# result_1 = a and b
# result_2 = a or b
# result_3 = b and c
# result_4 = c or d
# result_5 = not a
# result_6 = not c
# result_7 = a and d
# result_8 = f or d
# result_9 = a and e
# result_10 = b or f
# result_11 = not (c or f)

# print(result_11)


# TASK 2

# a_1 = 0
# a_2 = "1-20"
# b_1 = "21-40"
# b_2 = "41-60"
# c_1 = "61-80"
# c_2 = "81-100"


# number_of_words =  {
#     'A1': 500,
#     'A2': 1000,
#     'B1': 2000,
#     'B2': 4000,
#     'C1': 8000,
#     'C2': 16000
# }

# try:
#     test_result = int(input("Test result: "))

#     if test_result == 0:
#         print(f"The student has a A1 ({a_1}) level of English and approximately knows {number_of_words['A1']} words.")

#     elif test_result in range(1, 21):
#         print(f"The student has a A2 ({a_2}) level of English and approximately knows {number_of_words['A2']} words.")

#     elif test_result in range(21, 41):
#         print(f"The student has a B1 ({b_1}) level of English and approximately knows {number_of_words['B1']} words.")

#     elif test_result in range(41, 61):
#         print(f"The student has a B2 ({b_2}) level of English and approximately knows {number_of_words['B2']} words.")

#     elif test_result in range(61, 81):
#         print(f"The student has a C1 ({c_1}) level of English and approximately knows {number_of_words['C1']} words.")

#     elif test_result in range(81, 101):
#         print(f"The student has a C2 ({c_2}) level of English and approximately knows {number_of_words['C2']} words.")

#     else:
#         print("The input value must be from 0 to 100")

# except ValueError:
#     print("The input of variable test_result must have a numeric integer base")


# TASK 3

# try:
#     in_account  = float(input("Money on account: "))
#     goal = float(input("Monetary goal: "))
#     monthly_income = float(input("Monthly income: "))

#     if goal <= 0:
#         raise Exception("Goal must be greater than zero.")
#     if goal <= in_account:
#         raise Exception("Monetary goal must be greater than amount of money in the account")
#     if monthly_income <= 0:
#         raise Exception("Monthly income must be greater than zero.")

#     month = 0
#     while in_account < goal:
#         month += 1
#         in_account += monthly_income
#         remaining = max(goal - in_account, 0)  
#         print(f"{month} month. {in_account:.0f}€ has been raised. I need to raise {remaining:.0f}€.")

# except Exception as e:
#     print("Input error:", e)


# TASK 4

# sales = [250, 100, 150, 500, 750, 200]

# for i in enumerate(sales, start=1):
#     if i[1] > 500:
#         print(f"Sale #{i[0]} = {i[1]}, has a great value, bigger than 500")
#     else:
#         print(f"Sale #{i[0]}: {i[1]}")


# TASK 5

# text = "     nIce, CLEan TTTText!,,,, "

# text = text.strip(" ,").lower().replace("ttttext", "text")
# mylist = text.split()
# mylist[0] = mylist[0].capitalize()
# new_text = ' '.join(mylist)

# print(new_text)


# TASK 6

# print("445807".isdigit())     
# print("44-58-07".isdigit())    

# text = "every word from a capital letter"
# print(text.title()) 

# text = "Index of the first occurrence of substring"
# print(text.find("first"))  
# print(text.find("letter"))   


# TASK 7

# import re

# text = "Check the vindieselteam@gmail.com if you have questions about car repairs"
# pattern = r'\b[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b'
# result = re.findall(pattern, text)

# print(result)


# TASK 8

# vowel_letters = ["a", "e", "i", "o", "u", "y"]

# text = input("Enter some text: ").lower()  

# count = 0
# for letter in text:
#     if letter in vowel_letters:
#         count += 1

# print(f"Number of vowels: {count}")


# TASK 9

# text_01 = input("Type the first word: ").lower()
# text_02 = input("Type the second word: ").lower()

# mylist_01 = sorted(list(text_01))
# mylist_02 = sorted(list(text_02))

# if mylist_01 == mylist_02:
#     print("These words are anagrams")
# else:
#     print("Those words aren't anagrams")


# TASK 2 (alternate)

number_of_words = {
    'A1': 500,
    'A2': 1000,
    'B1': 2000,
    'B2': 4000,
    'C1': 8000,
    'C2': 16000
}

try:
    test_result = int(input("Test result (0-100): "))

    if test_result == 0:
        level = 'A1'
        score_range = "0"
    elif 1 <= test_result <= 20:
        level = 'A2'
        score_range = "1-20"
    elif 21 <= test_result <= 40:
        level = 'B1'
        score_range = "21-40"
    elif 41 <= test_result <= 60:
        level = 'B2'
        score_range = "41-60"
    elif 61 <= test_result <= 80:
        level = 'C1'
        score_range = "61-80"
    elif 81 <= test_result <= 100:
        level = 'C2'
        score_range = "81-100"
    else:
        print("The input value must be from 0 to 100.")
        exit()

    print(f"The student has a {level} ({score_range}) level of English and approximately knows {number_of_words[level]} words.")

except ValueError:
    print("The input of variable test_result must be an integer.")








