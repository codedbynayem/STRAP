import os
import shutil
import tkinter as tk
from tkinter import filedialog, simpledialog


def select_directory(prompt):
    """Open a dialog to select a directory."""
    root = tk.Tk()
    root.withdraw()  # Hide the root window
    directory = filedialog.askdirectory(title=prompt)
    return directory


def copy_specific_files(src_dir, dst_dir):
    # Get the parent folder name
    parent_folder_name = os.path.basename(os.path.normpath(src_dir))

    # Create the destination path including the parent folder
    dst_dir = os.path.join(dst_dir, parent_folder_name)

    # Define the file types and specific files to copy
    target_extensions = [".jpeg"]
    specific_files = ["Unfiltered_sptana.mat", "Filtered_sptana.mat", "imageBins.mat"]
    rpt_tracked_suffix = ".rpt_tracked.mat"

    # Walk through the source directory
    for dirpath, dirnames, filenames in os.walk(src_dir):
        for filename in filenames:
            # Check for files ending with .jpeg
            if filename.endswith(tuple(target_extensions)):
                copy_file(dirpath, filename, src_dir, dst_dir)

            # Check for the specific file names
            elif filename in specific_files and "Master_variables" in dirpath:
                copy_file(dirpath, filename, src_dir, dst_dir)

            # Check for files ending with .rpt_tracked.mat
            elif filename.endswith(rpt_tracked_suffix):
                copy_file(dirpath, filename, src_dir, dst_dir)


def copy_file(dirpath, filename, src_dir, dst_dir):
    """Helper function to copy the file to the destination directory."""
    # Construct full file path
    src_file_path = os.path.join(dirpath, filename)

    # Create the corresponding directory structure in the destination
    relative_path = os.path.relpath(dirpath, src_dir)
    dst_dir_path = os.path.join(dst_dir, relative_path)

    # Create the directory if it does not exist
    if not os.path.exists(dst_dir_path):
        os.makedirs(dst_dir_path)

    # Construct the full destination file path
    dst_file_path = os.path.join(dst_dir_path, filename)

    # Copy the file
    shutil.copy2(src_file_path, dst_file_path)
    print(f"Copied {src_file_path} to {dst_file_path}")


if __name__ == "__main__":
    # Prompt the user to select the source directory
    src_directory = select_directory("Select the folder to copy from")
    if not src_directory:
        print("No source folder selected. Operation cancelled.")
        exit()

    # Prompt the user to select the destination directory
    dst_directory = select_directory("Select the folder to copy to")
    if not dst_directory:
        print("No destination folder selected. Operation cancelled.")
        exit()

    # Perform the copying operation
    copy_specific_files(src_directory, dst_directory)
    print("File copying completed.")
