'''
p2problem3.py

This Involves choosing a dataset to load and filter it based on
a specified month and day.

Implement the load_data() function, which you can use directly in
your project. There are four steps:


1) Load the dataset for the specified city. Index the global
CITY_DATA dictionary object to get the corresponding filename
for the given city name.

2) Create month and day_of_week columns. Convert the "Start Time"
column to datetime and extract the month number and weekday name
into separate columns using the datetime module.

3) Filter by month. Since the month parameter is given as the
name of the month, you'll need to first convert this to the
corresponding month number. Then, select rows of the dataframe
that have the specified month and reassign this as the new dataframe.

4) Filter by day of week. Select rows of the dataframe that have
the specified day of week and reassign this as the new dataframe.
Note: Capitalize the day parameter with the title() method to
match the title case used in the day_of_week column.
'''

import pandas as pd

CITY_DATA = { 'chicago': 'chicago.csv',
              'new york city': 'new_york_city.csv',
              'washington': 'washington.csv' }

def load_data(city, month, day):
    """
    Loads data for the specified city and filters by month and day
    if applicable.

    Args:
        (str) city - name of the city to analyze
        (str) month - name of the month to filter by, or "all" to
                      apply no month filter
        (str) day - name of the day of week to filter by, or "all"
                    to apply no day filter
    Returns:
        df - pandas DataFrame containing city data filtered by
             month and day
    """

    # load data file into a dataframe
    df = pd.read_csv(CITY_DATA[city])
    print('\nORIGINAL')
    print(df.head(5))

    # convert the Start Time column to datetime
    df['Start Time'] = pd.to_datetime(df['Start Time'])

    # extract month and day of week from Start Time to create new columns
    df['month'] = df['Start Time'].dt.month
    df['day_of_month'] = df['Start Time'].dt.day
    # --------------------------------------------------------
    # Using dt.weekday_name is deprecated since pandas 0.23.0,
    # instead, use dt.day_name():
    df['day_of_week'] = df['Start Time'].dt.day_name()
    # df['day_of_week'] = df['Start Time'].dt.weekday_name

    print('\nCONVERTED Start Time, month, day_of_week')
    print(df.head(5))

    # filter by month if applicable
    if month != 'all':
        # use the index of the months list to get the corresponding int
        months = ['january', 'february', 'march', 'april', 'may', 'june']
        month = months.index(month) + 1
        print('month:', month)
        # filter by month to create the new dataframe
        df = df[df['month'] == month]
        print('\nFiltered by month == {}'.format(month))
        print(df.head(5))

    # filter by day of week if applicable
    if day != 'all':
        # filter by day of week to create the new dataframe
        df = df[df['day_of_week'] == day.title()]
        print('\nFiltered by Day of Week == {}'.format(day.title()))
        print(df.head(5))

    return df


def main():
    print("hello world!")
    df = load_data('chicago', 'march', 'friday')


if __name__ == "__main__":
    main()
