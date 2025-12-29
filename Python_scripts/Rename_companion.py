import os
import tkinter as tk
from tkinter import filedialog

def add_prefix_to_files(directory, prefix, file_extension):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(file_extension):
                old_file_path = os.path.join(root, file)
                new_file_name = prefix + file
                new_file_path = os.path.join(root, new_file_name)
                os.rename(old_file_path, new_file_path)
                print(f'Renamed: {old_file_path} to {new_file_path}')

def main():
    root = tk.Tk()
    root.withdraw()  # Hide the main tkinter window
    selected_directory = filedialog.askdirectory(title="Select the directory containing .companion.ome files")

    if selected_directory:
        add_prefix_to_files(selected_directory, 'companion_file_', '.companion.ome')
        print("All matching files have been renamed.")
    else:
        print("No directory was selected.")

if __name__ == "__main__":
    main()
