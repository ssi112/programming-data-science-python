"""
bikeshare.py

Use Python to explore data related to bike share systems for three major
cities in the United States: Chicago, New York City, and Washington.

Import the data and compute descriptive statistics.

Also write a script to take in raw input for an interactive experience
using the terminal to present these stats.

Programmer : Steve S Isenberg
Completed  : April 19, 2020
Revised    : April 22, 2020
GitHub     : https://github.com/ssi112/programming-data-science-python

Revision Notes:
Raw data is displayed upon request by the user in this manner:
Script should prompt the user if they want to see 5 lines of raw
data, display that data if the answer is 'yes', and continue
these prompts and displays until the user says 'no'.
"""

import time
import pandas as pd
import numpy as np
from datetime import timedelta

CITY_DATA = { 'chicago': 'chicago.csv',
              'new york city': 'new_york_city.csv',
              'washington': 'washington.csv' }

city_menu = { '1': 'Chicago',
              '2': 'New York City',
              '3': 'Washington',
              'x': 'Exit'}

month_menu = {'0': 'All',
              '1': 'January',
              '2': 'February',
              '3': 'March',
              '4': 'April',
              '5': 'May',
              '6': 'June',
              'x': 'Exit'}

weekday_menu = {'0': 'All',
                '1': 'Monday',
                '2': 'Tuesday',
                '3': 'Wednesday',
                '4': 'Thursday',
                '5': 'Friday',
                '6': 'Saturday',
                '7': 'Sunday',
                'x': 'Exit'}


def get_menu_item(menu):
    """
    Asks user to choose a menu item from one of the menu
    dictionaries defined above

    Returns:
        (str) selection - key of menu item chosen
    """
    while True:
        print('------------')
        print('Menu Options')
        print('------------')
        options = list(menu.keys())
        options.sort()
        for entry in options:
            print( entry, menu[entry] )
        selection = input("Please Select: ")
        # in case X entered for exit
        if selection.isupper():
            selection = selection.lower()
        if selection in options:
            # print(menu[selection])
            break
        else:
            print( "Unknown Option Selected!" )
    return selection


def get_filters():
    """
    Asks user to specify a city, month, and day to analyze.

    Returns:
        (str) city - name of the city to analyze
        (str) month - month number as string to filter on,
                      or "0" for all months (no month filter)
        (str) day - name of the day of week to filter by,
                    or "all" to apply no day filter
    """
    print('Hello! Let\'s explore some US bikeshare data!')
    # TO DO: get user input for city (chicago, new york city, washington).
    # HINT: Use a while loop to handle invalid inputs
    print('\nPlease select the city data to explore:\n')
    city = get_menu_item(city_menu)

    # TO DO: get user input for month (all, january, february, ... , june)
    print('\nPlease select the month:\n')
    month = get_menu_item(month_menu)

    # TO DO: get user input for day of week (all, monday, tuesday, ... sunday)
    print('\nPlease select the day of the week:\n')
    day = get_menu_item(weekday_menu)

    return city_menu[city].lower(), month, weekday_menu[day]


def load_data(city, month, day):
    """
    Loads data for the specified city and filters by month and day if applicable.

    Args:
        (str) city - name of the city to analyze
        (str) month - name of the month to filter by, or "all" to apply no month filter
        (str) day - name of the day of week to filter by, or "all" to apply no day filter
    Returns:
        df - Pandas DataFrame containing city data filtered by month and day
    """
    df = pd.read_csv(CITY_DATA[city])
    #print('\nORIGINAL')
    #print(df.head(5))

    # convert the Start Time column to datetime
    df['Start Time'] = pd.to_datetime(df['Start Time'])

    # extract month and day of week from Start Time to create new columns
    df['month'] = df['Start Time'].dt.month
    df['day_of_month'] = df['Start Time'].dt.day
    # =========================================================
    #  Using dt.weekday_name is deprecated since pandas 0.23.0
    #  instead use dt.day_name():
    # =========================================================
    df['day_of_week'] = df['Start Time'].dt.day_name()

    # filter by month if applicable
    if month != '0': # 0 = all
        # otherwise month comes in as a numeric string
        df = df[df['month'] == int(month)]

    # filter by day of week if applicable
    if day.lower() != 'all':
        # filter by day of week to create the new dataframe
        df = df[df['day_of_week'] == day.title()]

    #print('\nCONVERTED Start Time, month, day_of_week')
    #print(df.head(5))
    return df


def time_stats(df):
    """Displays statistics on the most frequent times of travel."""

    print('\nCalculating The Most Frequent Times of Travel...\n')
    start_time = time.time()

    # TO DO: display the most common month
    common_month = df['month'].mode()[0]
    print('Most common month is {}'.format(month_menu[str(common_month)]))


    # TO DO: display the most common day of week
    common_weekday = df['day_of_week'].mode()[0]
    print('Most common day of week is {}'.format(common_weekday))


    # TO DO: display the most common start hour
    # extract hour from the Start Time col to create an start hr col
    df['start_hour'] = df['Start Time'].dt.hour
    common_start_hour = df['start_hour'].mode()[0]

    ampm = ''
    if common_start_hour < 12:
        ampm = 'AM'
    else:
        common_start_hour -= 12
        ampm = 'PM'
    print('Most common start hour is {}{}'.format(common_start_hour, ampm))

    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)


def station_stats(df):
    """Displays statistics on the most popular stations and trip."""

    print('\nCalculating The Most Popular Stations and Trip...\n')
    start_time = time.time()

    # TO DO: display most commonly used start station
    common_start_station = df['Start Station'].mode()[0]
    print('Most common start station is {}'.format(common_start_station))

    # TO DO: display most commonly used end station
    common_end_station = df['End Station'].mode()[0]
    print('\nMost common end station is {}'.format(common_end_station))

    # TO DO: display most frequent combination of start station and end station trip
    # size method actually counts the rows in each group
    # also size returns a series, not a dataframe
    start_end_station = df.groupby(['Start Station', 'End Station']).size()
    """
    start_end_station looks like this:

    Start Station                 End Station
    2112 W Peterson Ave           2112 W Peterson Ave              1
                                  Broadway & Granville Ave         1
                                  Broadway & Thorndale Ave         3
                                  Clark St & Berwyn Ave            5
                                  Clark St & Bryn Mawr Ave         1
                                                                  ..
    Woodlawn Ave & Lake Park Ave  University Ave & 57th St        21
                                  Woodlawn Ave & 55th St           9
                                  Woodlawn Ave & Lake Park Ave     4
    Yates Blvd & 75th St          Stony Island Ave & 71st St       1
                                  Yates Blvd & 75th St             3
    """
    most_frequent_count = start_end_station.max()
    #print(start_end_station[start_end_station == most_frequent_count])

    start_end_stations = start_end_station[start_end_station == most_frequent_count].index[0]

    print('\nThe most frequent combination of start and end trip stations are:')
    print('\tStart Station:', start_end_stations[0])
    print('\tEnd Station:', start_end_stations[1])
    print('\tCount of trips:', most_frequent_count)

    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)


def trip_duration_stats(df):
    """Displays statistics on the total and average trip duration."""

    print('\nCalculating Trip Duration...\n')
    start_time = time.time()

    # TO DO: display total travel time
    tot_travel_time = df['Trip Duration'].sum()
    tot_time = int(tot_travel_time)
    day = tot_time // (24 * 3600)
    tot_time = tot_time % (24 * 3600)
    hour = tot_time // 3600
    tot_time %= 3600
    minutes = tot_time // 60
    tot_time %= 60
    seconds = tot_time
    print('Total Trip Duration: {:,d} days: {:d} hours: {:d} minutes: {:d} seconds'
        .format(day, hour, minutes, seconds))

    # TO DO: display mean travel time
    avg_travel_time = df['Trip Duration'].mean()

    minutes, seconds = divmod(avg_travel_time, 60)
    hours, minutes = divmod(minutes, 60)
    #print('avg_travel_time:', avg_travel_time)
    print('Average Trip Duration: {:.2f} hours {:.2f} minutes {:.2f} seconds'.
           format(hours, minutes, seconds))

    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)


def user_stats(df):
    """Displays statistics on bikeshare users."""

    print('\nCalculating User Stats...\n')
    start_time = time.time()

    #print(df.columns.values)
    # TO DO: Display counts of user types
    print('Counts by user type:\n--------------------')
    print(df.groupby(['User Type']).size())

    # TO DO: Display counts of gender
    if 'Gender' in df: #.index.values:
        print('\nCounts by gender:\n--------------------')
        #print(df.groupby(['Gender']).size())

        g = df.groupby(['Gender']).size()
        gender_values = g.tolist()
        gender_names = df.groupby(['Gender']).size().index.get_level_values(0).tolist()
        #print(g[0], g[1])
        #print(glist)
        print('{}: {:,}'.format(gender_names[0], gender_values[0]))
        print('{}: {:,}'.format(gender_names[1], gender_values[1]))
    else:
        print("\nNo Gender Data Available!")

    # TO DO: Display earliest, most recent, and most common year of birth
    if 'Birth Year' in df:
        earliest_birth_year = int(df['Birth Year'].min())
        recent_birth_year = int(df['Birth Year'].max())
        common_birth_year = int(df['Birth Year'].mode())
        print('\nUser birth year data:\n---------------------')
        print('Oldest (earliest) birth year:', earliest_birth_year)
        print('Youngest (most recent) birth year:', recent_birth_year)
        print('Most common birth year:', common_birth_year)
    else:
        print("\nNo Birth Year Data Available!")

    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)


def show_raw_data(df):
    """
    """
    row_cnt = df.shape[0] # number of rows
    start_row = 0 # used to paginate through the dataframe
    page_size = 5
    end_row = 0
    prompt_string = "Would you like to see some of the raw data?"

    while start_row < row_cnt:
        print()
        print('-'*70)
        print(prompt_string)
        show_me = input("Enter [Y]es or any other key to quit: ")
        if show_me == '': # user hit enter
            break

        if show_me[0].lower() == 'y':
            print("How many rows of data would you like to see?")
            print("The default is five. The max is twenty")
            page_size = input("Enter number of rows to display between 5 and 20: ")
            if page_size != '': # user hit enter - no input
                page_size = int(page_size)
            else:
                page_size = 5

            if 5 <= page_size <= 20:
                end_row = end_row + page_size
            else:
                page_size = 5
                end_row = end_row + page_size
            print("\n>>> Showing rows {} to {} of data:".format(start_row+1, end_row))
            if end_row > row_cnt:
                end_row = row_cnt
            print(df.iloc[start_row:end_row])
            start_row = end_row
            #end_row = end_row + page_size
            prompt_string = "Would you like to see more raw data?"
        else:
            break
    print("\nReturning to main...")


def main():
    while True:
        city, month, day = get_filters()
        print('\n--------------------')
        print('  Your Selections:')
        print('--------------------')
        print('City:', city.title())
        print('Month:', month_menu[month])
        print('Day:', day)

        # in case the user did not make a selection
        if city.lower() != 'exit' and month.lower() != 'x' and day.lower() != 'exit':
            df = load_data(city, month, day)
            time_stats(df)
            station_stats(df)
            trip_duration_stats(df)
            user_stats(df)
            show_raw_data(df)

        restart = input('\nWould you like to restart? Enter [Y]es or any other key to quit: ')
        if restart == '': # user hit enter
            break
        if restart[0] == 'Y' or restart[0].lower() == 'y':
            continue
        else:
            break


if __name__ == "__main__":
	main()
