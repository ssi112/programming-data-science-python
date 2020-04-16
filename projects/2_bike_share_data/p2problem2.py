'''
p2problem2.py

There are different types of users specified in the "User Type"
column.

Find how many there are of each type and store the counts in a
pandas Series in the user_types variable.

Hint: What pandas function returns a Series with the counts of each unique value in a column?

'''
import pandas as pd

filename = 'chicago.csv'

# load data file into a dataframe
df = pd.read_csv(filename)
print('\nORIGINAL')
print(df.head(5))

# print value counts for each user type
user_types = df['User Type'].value_counts()


print()
print('-'*55)
print(user_types)
print('-'*55)



