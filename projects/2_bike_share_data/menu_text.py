# menu_text.py
#
# simple python menu
# https://stackoverflow.com/questions/19964603/creating-a-menu-in-python
#

menu = {}
menu['1'] = "Add Student"
menu['5'] = "Promote Student"
menu['2'] = "Delete Student"
menu['3'] = "Find Student"
menu['4'] = "Exit"
while True:
    options = list(menu.keys())
    options.sort()
    for entry in options:
        print( entry, menu[entry] )
    selection = input("Please Select: ")
    if selection == '1':
        print( "add" )
    elif selection == '2':
        print( "delete" )
    elif selection == '3':
        print( "find" )
    elif selection == '4':
        break
    else:
        print( "Unknown Option Selected!" )
