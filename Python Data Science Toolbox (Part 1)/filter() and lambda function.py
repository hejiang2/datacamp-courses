# In simple words, filter() method filters the given iterable with the help of a function that tests each element in the iterable to be true or not.
# filter(function, iterable)
# function that tests if elements of an iterable return true or false
If None, the function defaults to Identity function - which returns false if any elements are false
# iterable which is to be filtered, could be sets, lists, tuples, or containers of any iterators

# Create a list of strings: fellowship
fellowship = ['frodo', 'samwise', 'merry', 'pippin', 'aragorn', 'boromir', 'legolas', 'gimli', 'gandalf']

# Use filter() to apply a lambda function over fellowship: result
result = filter(lambda member: len(member)>6, fellowship)

# Convert result to a list: result_list
result_list = list(result)

# Print result_list
print(result_list)