import datetime
import os


def is_system_path(path):
    system_paths = [
        "~/Desktop",
        "/System",
        "/Documents/Git" "/Applications",
        "/Library",
        "/usr",
        "/bin",
        "/sbin",
        "/var",
        "/private",
        "/etc",
        "/tmp",
        "/.",
        "/Python",
    ]
    return any(path.startswith(system_path) for system_path in system_paths)


directory_to_search = input(
    "Please enter the directory to search for .png and .jpg files: "
)

if is_system_path(directory_to_search):
    print("System directories are not allowed.")
    exit()

current_date = datetime.datetime.now().strftime("%Y%m%d")
directory_name = os.path.basename(os.path.normpath(directory_to_search))
filename = f"{directory_name}_Images_{current_date}.csv"
output_file = os.path.join(directory_to_search, filename)

with open(output_file, "w") as file:
    file.write("FilePath\n")

    for dirpath, dirnames, filenames in os.walk(directory_to_search):
        if is_system_path(dirpath):
            continue

        for filename in filenames:
            if filename.lower().endswith((".png", ".jpg", ".jpeg")):
                file_path = os.path.join(dirpath, filename)
                file.write(f"{file_path}\n")

print(f"Image files have been listed in {output_file}")
