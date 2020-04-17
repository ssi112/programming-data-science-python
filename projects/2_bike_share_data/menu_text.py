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
            #print(menu[selection])
            break
        else:
            print( "Unknown Option Selected!" )
    return selection


def main():
    city_selected = get_menu_item(city_menu)
    print('\n Selected Selected City: ', city_menu[city_selected])

    month_selected = get_menu_item(month_menu)
    print('\n Selected Month: ', month_menu[month_selected])
    print("month", month_selected)

    day_selected = get_menu_item(weekday_menu)
    print('\n Selected Weekday: ', weekday_menu[day_selected])

if __name__ == "__main__":
    main()
