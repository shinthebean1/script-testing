import tkinter as tk

root = tk.Tk()

root.geometry("500x500")
root.title("my gui")

label = tk.Label(root, text="hello world", font=('Arial', 18))
label.pack(padx=20, pady=20)

textbox = tk.Text(root, height=3, font=('Arial', 16))
textbox.pack(padx=10, pady=10)

button = tk.Button(root, text="Click me!", font=('Arial, 18'))
button.pack(padx=10, pady=10)

root.mainloop()