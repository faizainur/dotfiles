import os

HOME_PATH = os.environ["HOME"]
CWD = os.getcwd()

SYMLINK_ZSHRC_PATH = HOME_PATH + "/.zshrc"
SYMLINK_BASHRC_PATH = HOME_PATH + "/.bashrc"
SYMLINK_GITCONFIG_PATH = HOME_PATH + "/.gitconfig"

ZSHRC_PATH = CWD + "/.zshrc"
BASHRC_PATH = CWD + "/.bashrc"
GITCONFIG_PATH = CWD + "/.gitconfig"


# Create  symlinks
print("Creating symlink...")
try:
    os.symlink(ZSHRC_PATH, SYMLINK_ZSHRC_PATH)
    os.symlink(BASHRC_PATH, SYMLINK_BASHRC_PATH)
    os.symlink(GITCONFIG_PATH, SYMLINK_GITCONFIG_PATH)
except BaseException as error:
    print(f"An Error Occured: {format(error)}")
print("Done")