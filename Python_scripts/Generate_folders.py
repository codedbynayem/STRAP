import os
import tkinter as tk
from tkinter import filedialog
import sys


def get_number_of_channels():
    while True:
        try:
            num_channels = int(input("How many channels were used for imaging? (1-4):"))
            if 1 <= num_channels <= 4:
                return num_channels
            else:
                print("Invalid number of channels. Please enter a number between 1 and 4.")
        except ValueError:
            print("Invalid input. Please enter a valid integer.")


def get_channel_names(num_channels):
    channels = []
    for i in range(1, num_channels + 1):
        while True:
            channel_name = input(f"What is the name of channel {i}?: ").strip()
            if channel_name:
                channels.append(channel_name)
                break
            else:
                print("Channel name cannot be empty. Please enter a valid name.")
    return channels


def create_channel_folders(root_directory, num_FOV, channels):
    for i, channel_name in enumerate(channels, start=1):
        channel_folder = os.path.join(root_directory, f"{i}_{channel_name}")
        processed_folder = os.path.join(channel_folder, "Processed_imaging_data")
        fov_folder = os.path.join(processed_folder, "FOV")
        photobleach_folder = os.path.join(processed_folder, "Photobleach_standards")
        master_variables_folder = os.path.join(processed_folder, "Master_variables")

        os.makedirs(fov_folder, exist_ok=True)
        os.makedirs(photobleach_folder, exist_ok=True)
        os.makedirs(master_variables_folder, exist_ok=True)

        for j in range(1, num_FOV + 1):
            os.makedirs(os.path.join(fov_folder, f'FOV_{j}'), exist_ok=True)

        print(f"Folder structure for channel '{channel_name}' created successfully.")


def main():
    try:
        num_channels = get_number_of_channels()
        channels = get_channel_names(num_channels)
        num_FOV = int(input("Enter the number of FOV folders to create: "))

        root = tk.Tk()
        root.withdraw()
        root_directory = filedialog.askdirectory(title="Select Root Directory")

        if not root_directory:
            print("No directory selected. Operation cancelled.")
            exit()

        create_channel_folders(root_directory, num_FOV, channels)

    except ValueError:
        print("Invalid input. Please enter a valid integer.")


if __name__ == "__main__":
    main()
