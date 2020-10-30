# The following is a simple example of a Python closure.
def make_printer(msg):

    msg = "hi there"

    def printer():
        print(msg)

    return printer


myprinter = make_printer("Hello there")
myprinter()
myprinter()
myprinter()

# In the example, we have a make_printer() function, which creates and returns a function. The nested printer() function is the closure.
# The make_printer() function returns a printer() function and assigns it to the myprinter variable. At this moment, it has finished its execution. However, the printer() closure still has access to the msg variable.
