// ImageJ Macro to manually select and save multiple ROIs for photobleach calc
// Created by Nayem H., 05/21/2024 v3.3

// Clear ROI Manager at the start of the script
roiManager("reset");

// Declare global variables
var photobleach_path;
var cropped_processed_path;
var roiX, roiY, roiWidth, roiHeight;

// Display initial user-friendly message
showMessage("Load TIFF Files", "Please make sure channel-separated (if applicable) TIFF files are loaded into Fiji/ImageJ before proceeding.");

// Function to validate the selected folder
function validateAndCreatePaths(baseDir, fovNumber) {
    var fovFolder = "FOV_" + fovNumber;
    var fovDir = baseDir + "FOV" + File.separator + fovFolder + File.separator;
    
    if (!File.exists(fovDir) ||
        !File.exists(baseDir + "Master_variables" + File.separator) ||
        !File.exists(baseDir + "Photobleach_standards" + File.separator)) {
        exit("Selected folder does not contain the required subfolders ('FOV/FOV_X', 'Master_variables', 'Photobleach_standards').");
    }

    cropped_processed_path = fovDir;
    photobleach_path = baseDir + "Photobleach_standards" + File.separator;

    print("Cropped Processed Path: " + cropped_processed_path);
    print("Photobleach Path: " + photobleach_path);
}

// Function to extract FOV number from the filename
function extractFOVNumber(filename) {
    fovIndex = indexOf(filename, "FOV_");
    if (fovIndex == -1) {
        exit("FOV number not found in filename.");
    }
    
    underscoreIndex = indexOf(filename, "_", fovIndex + 4);
    if (underscoreIndex == -1) {
        exit("Could not determine the end of FOV number.");
    }
    
    fovNumber = substring(filename, fovIndex + 4, underscoreIndex);
    return fovNumber;
}

// Function to store ROI coordinates
function storeROICoordinates() {
    roiCount = roiManager("count");
    roiX = newArray(roiCount);
    roiY = newArray(roiCount);
    roiWidth = newArray(roiCount);
    roiHeight = newArray(roiCount);
    
    for (i = 0; i < roiCount; i++) {
        roiManager("Select", i);
        getSelectionBounds(x, y, width, height);
        roiX[i] = x;
        roiY[i] = y;
        roiWidth[i] = width;
        roiHeight[i] = height;
    }
}

// Function to restore and add original ROIs
function restoreOriginalROIs() {
    for (i = 0; i < roiX.length; i++) {
        makeRectangle(roiX[i], roiY[i], roiWidth[i], roiHeight[i]);
        roiManager("Add");
    }
}

// Function to process and save ROIs to the specified path
function processROIs(originalBaseName, savePath, expand) {
    for (i = 0; i < roiX.length; i++) {
        if (expand) {
            // Expand the ROI by 50% from the center
            newWidth = roiWidth[i] * 1.5;
            newHeight = roiHeight[i] * 1.5;
            newX = roiX[i] - (newWidth - roiWidth[i]) / 2;
            newY = roiY[i] - (newHeight - roiHeight[i]) / 2;

            makeRectangle(newX, newY, newWidth, newHeight);
        } else {
            makeRectangle(roiX[i], roiY[i], roiWidth[i], roiHeight[i]);
        }

        run("Duplicate...", "title=crop50_" + (i+1) + " duplicate all");
        run("Enhance Contrast", "saturated=0.35");
        if (expand) {
            run("Subtract Background...", "rolling=50 stack");
            run("Enhance Contrast", "saturated=0.35");
        }

        newFileName = "crop50_" + originalBaseName + "_ROI_" + (i+1) + ".tif";
        saveAs("Tiff", savePath + newFileName);
        close();
    }
    print("ROIs processed and saved to " + savePath);
}

// Function to process a single channel
function processChannel(channelNumber) {
    originalTitle = getTitle();
    dotIndex = indexOf(originalTitle, ".");
    if (dotIndex != -1) {
        baseName = substring(originalTitle, 0, dotIndex);
    } else {
        baseName = originalTitle;
    }

    // Extract FOV number from the filename
    fovNumber = extractFOVNumber(originalTitle);

    // Display user-friendly message
    showMessage("Channel " + channelNumber + " Selection", "Please select the 'Processed_imaging_data' folder for Channel " + channelNumber + ".");

    // Allow user to select the "Processed_imaging_data" folder for this channel
    baseDir = getDirectory("Please select 'Processed_imaging_data' folder for Channel " + channelNumber);
    if (baseDir == "") {
        exit("No directory selected. Macro canceled.");
    }

    // Validate the folder and create paths for the current channel
    validateAndCreatePaths(baseDir, fovNumber);

    // Store the coordinates of the selected ROIs
    storeROICoordinates();

    // Process and save expanded ROIs to the FOV folder
    processROIs(baseName, cropped_processed_path, true);

    // Reset the ROI Manager and restore the original ROIs
    roiManager("reset");
    restoreOriginalROIs();

    // Process and save original ROIs to the Photobleach_standards folder
    processROIs(baseName, photobleach_path, false);
}

// Main Macro

if (nImages == 0) {
    exit("Please open an image first.");
}

numberOfROIs = getNumber("Enter the number of ROIs to select:", 3);
roiManager("reset");

for (i = 0; i < numberOfROIs; i++) {
    waitForUser("Select ROI #" + (i+1) + " and click OK");
    roiManager("Add");
}

// Process the first channel
processChannel(1);

// Process additional channels dynamically
while (true) {
    if (nImages > 1) {
        waitForUser("Please click on the next channel window. Then click OK to continue or Cancel to stop.");

        if (nImages == 0) {
            exit("No image loaded. Exiting macro.");
        }

        channelNumber = getNumber("Enter the channel number (e.g., 2, 3, ...):", 2);
        processChannel(channelNumber);

        choice = getBoolean("Do you want to process another channel?", "Yes", "No");
        if (choice == false || channelNumber >= 4) {
            break;
        }
    }
}

print("All channels processed successfully.");
