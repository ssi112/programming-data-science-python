# menu_text.py
#
# simple python menu
# https://stackoverflow.com/questions/19964603/creating-a-menu-in-python
#

city_menu = { '1': 'Chicago',
              '2': 'New York',
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
            print(menu[selection])
            break
        else:
            print( "Unknown Option Selected!" )
    return selection

option_selected = get_menu_item(city_menu)
print('\n City: ', city_menu[option_selected])

option_selected = get_menu_item(month_menu)
print('\n Month: ', month_menu[option_selected])

option_selected = get_menu_item(weekday_menu)
print('\n Weekday: ', weekday_menu[option_selected])

